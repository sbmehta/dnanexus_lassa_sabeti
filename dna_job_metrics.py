#!/usr/bin/env python

import argparse
import csv
import sys
import concurrent.futures
import datetime
import re
import multiprocessing

import dxpy

top_level_execution_attributes_to_include = ['id', 'executableName', 'folder', 'name', 'state', 'launchedBy', 'parentAnalysis']

parser = argparse.ArgumentParser(
            description="""Returns output metrics from DNAnexus.
                        If a project ID is given, information is returned for all jobs/analyses within the project."""
            )
parser.add_argument('csvfile', type=argparse.FileType('w'), help='Output file')
parser.add_argument('ids', type=str, nargs='+', help='One of {project-<ID>, analysis-<ID>, or job-<ID>}')
parser.add_argument('--state', dest='states', nargs='+', choices=["done", "failed", "running", "terminated", "runnable"], default=None, help="States to include. Note: 'runnable' means waiting to be executed.")
parser.add_argument('--executableName', dest='executable_names', nargs='+', default=None, help="DNAnexus executable names to include. If omitted, all are included.")
parser.add_argument('--noDescendants', dest='no_descendants', action='store_true', help="Include top-level executions only. Default is false.")
parser.add_argument('--createdAfter', dest='created_after', nargs='?', default="10y", help='Integer integer suffixed with one of [smdwy], interpreted as time before now. Default is 10y.')
parser.add_argument('--createdBefore', dest='created_before', nargs='?', default="1s", help='Integer suffixed with one of [smdwy], interpreted as time before now. Default is 1s.')



def available_cpu_count():
    """
    Return # virtual or physical CPUs on this system.
    The number of available CPUs can be smaller than the total number of CPUs
    when the cpuset(7) mechanism is in use, as is the case on some cluster
    systems.
    Adapted from http://stackoverflow.com/a/1006301/715090
    """
    try:
        with open('/proc/self/status') as f:
            status = f.read()
        m = re.search(r'(?m)^Cpus_allowed:\s*(.*)$', status)
        if m:
            res = bin(int(m.group(1).replace(',', ''), 16)).count('1')
            if res > 0:
                return min(res, multiprocessing.cpu_count())
    except IOError:
        pass

    return multiprocessing.cpu_count()



if __name__ == "__main__":
    if len(sys.argv)==1:
        parser.print_help()
        sys.exit(0)

    args = parser.parse_args()

    analysis_ids = filter(lambda s: s.startswith("analysis-"), args.ids)
    project_ids  = filter(lambda s: s.startswith("project-"),  args.ids)
    job_ids      = filter(lambda s: s.startswith("job-"),      args.ids)

    executions = []

    created_after = "-" + args.created_after
    created_before = "-" + args.created_before

    #if not args.created_after:
    #    args.created_after = 0     # default is everything since the Unix epoch
    #if not args.created_before:
    #    args.created_before = -1   # default is everything upto 1ms ago

    project_job_ids = []
    if project_ids:
        for project_id in project_ids:
            if args.states:
                for state in args.states:
                    project_job_ids.extend([e["id"] for e in dxpy.find_executions(project=project_id, state=state, created_after=created_after, created_before=created_before)])
            else:
                project_job_ids.extend([e["id"] for e in dxpy.find_executions(project=project_id, created_after=created_after, created_before=created_before)])

    execution_ids_to_describe = list(set(analysis_ids+project_job_ids+job_ids))

    print("Reading {} total executions...".format(len(execution_ids_to_describe)))

    with concurrent.futures.ThreadPoolExecutor(max_workers=available_cpu_count()) as executor:
        for execution in executor.map(dxpy.describe, execution_ids_to_describe, chunksize=50):
            executions.append(execution)

    all_metrics = []
    keys_seen = set()
    for execution in executions:
        metrics = {}

        if args.no_descendants:
            if "parentAnalysis" in execution and execution["parentAnalysis"] is not None:
                continue
        if args.executable_names:
            if "executableName" in execution and execution["executableName"] not in args.executable_names:
                continue

        metrics=dict([(x,execution[x]) for x in top_level_execution_attributes_to_include if x in execution])
        metrics["created"] = datetime.datetime.utcfromtimestamp(float(execution["created"])/1000).isoformat()
        keys_seen.update(metrics.keys())

        for execution_key in ["output"]:
            if execution_key in execution and execution[execution_key] is not None:
                for key, value in execution[execution_key].items():
                    if (type(value) == int or type(value) == float):
                        field_name=key.split(".")[-1]
                        metrics[field_name] = value
                        keys_seen.add(field_name)

        all_metrics.append(metrics)

    with args.csvfile as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=sorted(keys_seen))
        writer.writeheader()
        writer.writerows(all_metrics)

    print("Metrics written for {} execution objects.".format(len(all_metrics)))

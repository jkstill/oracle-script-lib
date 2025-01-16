
@autotask_sql_setup
@autotask_auto_stats_disable
@autotask_auto_tasks_disable.sql
@disable_resource_manager

-- Oracle sometimes enforces Resource Manager for background processes
-- does not work in PDB
alter system set resource_manager_cpu_allocation=0 scope=both;


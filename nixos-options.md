## services\.sandkasten\.enable

Whether to enable sandkasten\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.package



The sandkasten package to use\.



*Type:*
package



*Default:*

```nix
sandkasten.packages.${system}.sandkasten
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.environments



Sandkasten packages to install\.



*Type:*
function that evaluates to a(n) package



*Default:*

```nix
sandkastenPackages: sandkastenPackages.all
```



*Example:*

```nix
sandkastenPackages: sandkastenPackages.select (p: with p; [
  python
  rust
])

```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.nsjailPackage



The nsjail package to use\.



*Type:*
package



*Default:*

```nix
pkgs.nsjail
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings



Sandkasten configuration\.



*Type:*
open submodule of (TOML value)



*Default:*

```nix
{ }
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.enable_metrics



Whether to expose Prometheus metrics on ` /metrics `\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.base_resource_usage



Config for measuring the base resource usage of an environment\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.base_resource_usage\.cache_ttl



The time to live for base resource usage cache entries in seconds\.



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
3600
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.base_resource_usage\.permits



The number of permits to acquire from the internal request semaphore\.
If set to the value of [](\#opt-services\.sandkasten\.settings\.max_concurrent_jobs)
or more (the default), no other jobs can run at the same time\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
config.services.sandkasten.settings.max_concurrent_jobs
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.base_resource_usage\.runs



The number of times the program is run\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
20
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.compile_limits



The maximum allowed limits for compile steps\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.compile_limits\.cpus



The maximum number of cpus the process is allowed to use\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
1
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.compile_limits\.file_descriptors



The maximum number of file descripters the process can open at the same time\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
256
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.compile_limits\.filesize



The maximum size of a file the process is allowed to create (in **MB**)\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
16
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.compile_limits\.memory



The amount of memory the process is allowed to use (in **MB**)\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
1024
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.compile_limits\.network



Whether the process is allowed to access the network\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.compile_limits\.processes



The maximum number of processes that can run concurrently in the sandbox\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
256
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.compile_limits\.stderr_max_size



The maximum number of bytes that are read from stderr\.



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
65536
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.compile_limits\.stdout_max_size



The maximum number of bytes that are read from stdout\.



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
65536
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.compile_limits\.time



The number of **seconds** the process is allowed to run\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
30
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.compile_limits\.tmpfs



The size of the tmpfs mounted at /tmp (in **MB**)\.



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
256
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.host



The host to listen on\.



*Type:*
string



*Default:*

```nix
"127.0.0.1"
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.jobs_dir



The directory where files for jobs are stored\.



*Type:*
absolute path



*Default:*

```nix
"/run/sandkasten/jobs"
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.max_concurrent_jobs



The maximum number of jobs that can run at the same time\.



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
4
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.port



The port to listen on\.



*Type:*
16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
8000
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.program_ttl



The time to live for programs in seconds\.



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
600
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.programs_dir



The directory where programs are stored\.



*Type:*
absolute path



*Default:*

```nix
"/var/lib/sandkasten/programs"
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.prune_programs_interval



The number of seconds to wait between deleting old programs\.



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
60
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.run_limits



The maximum allowed limits for run steps\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.run_limits\.cpus



The maximum number of cpus the process is allowed to use\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
1
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.run_limits\.file_descriptors



The maximum number of file descripters the process can open at the same time\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
256
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.run_limits\.filesize



The maximum size of a file the process is allowed to create (in **MB**)\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
16
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.run_limits\.memory



The amount of memory the process is allowed to use (in **MB**)\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
256
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.run_limits\.network



Whether the process is allowed to access the network\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.run_limits\.processes



The maximum number of processes that can run concurrently in the sandbox\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
64
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.run_limits\.stderr_max_size



The maximum number of bytes that are read from stderr\.



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
65536
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.run_limits\.stdout_max_size



The maximum number of bytes that are read from stdout\.



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
65536
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.run_limits\.time



The number of **seconds** the process is allowed to run\.



*Type:*
positive integer, meaning >0



*Default:*

```nix
5
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.run_limits\.tmpfs



The size of the tmpfs mounted at /tmp (in **MB**)\.



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
256
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.settings\.server



The path prefix added by a reverse proxy\.
Set to ` "/" ` if you don’t have a reverse proxy\.



*Type:*
string



*Default:*

```nix
"/"
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## services\.sandkasten\.timePackage



The time package to use\.



*Type:*
package



*Default:*

```nix
sandkasten.packages.${system}.time
```

*Declared by:*
 - [nix/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/module\.nix)



## compile

Compile script\.



*Type:*
null or (submodule)



*Default:*

```nix
null
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## compile\.environment



Environment variables\.



*Type:*
attribute set of string



*Default:*

```nix
{ }
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## compile\.path



List of packages to add to the PATH\.



*Type:*
list of package



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## compile\.script



The script\.



*Type:*
string

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## default_main_file_name



Default file name for the main entrypoint into the program\.



*Type:*
string



*Example:*

```nix
"code.rs"
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## example



Program example\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
''
  fn main() {
      println!("Hello, world!");
  }
''
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## id



Unique identifier of the environment\.



*Type:*
string



*Example:*

```nix
"rust"
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## meta



Additional metadata\.



*Type:*
attribute set of (JSON value)



*Default:*

```nix
{ }
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## name



Name of the environment\.



*Type:*
string



*Example:*

```nix
"Rust"
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## run



Run script\.



*Type:*
submodule

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## run\.environment



Environment variables\.



*Type:*
attribute set of string



*Default:*

```nix
{ }
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## run\.path



List of packages to add to the PATH\.



*Type:*
list of package



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## run\.script



The script\.



*Type:*
string

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## test



Integration test to verify basic functionality of this environment\.



*Type:*
submodule

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## test\.expected



Expected output of stdout after removing leading and trailing whitespace\.



*Type:*
string



*Default:*

```nix
"OK"
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## test\.files



List of additional source files\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## test\.files\.\*\.content



File content\.



*Type:*
string



*Example:*

```nix
''
  fn main() {
    println!("OK");
  }
''
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## test\.files\.\*\.name



File name\.



*Type:*
string



*Example:*

```nix
"test.rs"
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## test\.main_file



Main source file\.



*Type:*
submodule

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## test\.main_file\.content



File content\.



*Type:*
string



*Example:*

```nix
''
  fn main() {
    println!("OK");
  }
''
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## test\.main_file\.name



File name\.



*Type:*
string



*Example:*

```nix
"test.rs"
```

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



## version



Version of the environment\.



*Type:*
string

*Declared by:*
 - [nix/packages/module\.nix](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree/nix/packages/module\.nix)



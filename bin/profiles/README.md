Load Profile Tools
------------------

#### Setup

1. Install Slop: `gem install slop --version '>= 4.0.0'`.
2. ???
3. Profit!

#### Using `split`

The `split` tool will take a large CSV from the Load Profile Generator and
produce a separate CSV file for each technology. Provide the path to the load
profile as the only argument.

```sh
./split MyLittleProfile.csv
```

A new time-stamped directory will be created containing the technology profiles,
and the path to each CSV is shown to you.

#### Using `sample`

`sample` takes one or more technology profiles, and creates derivatives
containing fewer points. This is useful if the one point per minute frequency of
the original is too high, and you instead want one point per fifteen minutes,
one per hour, etc. `sample` will select the highest load in each time period,
and use that as the new value.

For example, a curve containing eight points: `[2, 4, 3, 5, 6, 3, 9, 4]` would
be down-sampled to a curve containing four points like so:

| Original Points | New Point | Original Values | New Value |
| :-------------: | :-------: | :-------------: | --------: |
| 0 & 1           | 0         | 1, 4            | 4         |
| 2 & 3           | 1         | 3, 5            | 5         |
| 4 & 5           | 2         | 6, 3            | 6         |
| 6 & 7           | 3         | 9, 4            | 9         |

You should provide `sample` with a list of files you want to be sampled – or a
path to a directory containing one or more files – and a path to the directory
where the new sample files will be written:

```sh
# Single input file
./sample my-huge.csv finished-curves

# Multiple input files
./sample left.csv right.csv finished-curves

# Path to a directory containing many source curves
./sample per-minute-curves sampled-curves
```

##### Option: `--samples` (default: 8760)

Choose how many points you want in your sampled curves by supplying a
`--samples` option:

```sh
./sample my-huge.csv finished-curves --samples 365
```

You may create multiple sampled curves simultaneously by comma-separating the
number of desired samples. Downsample a per-minute curve into two separate
curve files – one with per-hour values, and one with per-quarter-hour values –
like so:

```sh
./sample per-minute.csv finished-curves --samples 8760,35040
```

##### Option: `--verbose`

Supply the `--verbose` option to receive a message when each technology curve
has been processed. Useful if the script is expected to take a long time.

#### Using both together

Be a pro and pipe the output of `split` into `sample` to combine both steps into
one! When doing this, you can omit the path to the technology curves produced
by `split`.

```sh
./split MyLittleProfile.csv | ./sample finished-curves --samples 8760,35040
```

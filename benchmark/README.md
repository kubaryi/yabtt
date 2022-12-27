# Benchmark :100:

We used [Benchee](https://github.com/bencheeorg/benchee) as a framework to write a simple, (possibly) unscientific Benchmark.

## Defense

We pair **_`100` users_**, **_`1000` users_** and **_`10,000` users_** with **_`100` BitTorrents_**, **_`1000` BitTorrents_** and **_`10,000` BitTorrents_** one by one to form a **`3` &#215; `3` matrix**, and obtained a total of `9` groups of cases. Then use functions to randomly generate `Request` based on cases in each run to **imitate the performance of users of different sizes in accessing the server in different numbers of BitTorrents lists**.

```txt
            User  User  User
BitTorrent [[100, 1000, 10_000],    a functions to randomly gen `Request`
BitTorrent  [100, 1000, 10_000],  ----------------------------------------->  &Benchee.run/2
BitTorrent  [100, 1000, 10_000]]
```

## Report

<details>
  <summary><b>System info</b></summary>
    <ul>
      <li>Application Version: 0.0.1</li>
      <li>Elixir Version: 1.14.2</li>
      <li>Erlang Version: 25.2</li>
      <li>Operating system: Linux</li>
      <li>Available memory: 2.86 GB</li>
      <li>Number of Available Cores: 4</li>
    </ul>
</details>

### Large number of BitTorrents

| Name                     | Iterations per Second | Average | Deviation | Median | Mode | Minimum | Maximum | Sample size |
| :----------------------- | --------------------: | ------: | --------: | -----: | ---: | ------: | ------: | ----------: |
| large number of users    |                       |         |           |        |      |         |         |             |
| moderate number of users |                       |         |           |        |      |         |         |             |
| small number of users    |                       |         |           |        |      |         |         |             |

### Medium number of BitTorrents

| Name                     | Iterations per Second | Average | Deviation | Median | Mode | Minimum | Maximum | Sample size |
| :----------------------- | --------------------: | ------: | --------: | -----: | ---: | ------: | ------: | ----------: |
| large number of users    |                       |         |           |        |      |         |         |             |
| moderate number of users |                       |         |           |        |      |         |         |             |
| small number of users    |                       |         |           |        |      |         |         |             |

### Small amount of BitTorrent

| Name                     | Iterations per Second | Average | Deviation | Median | Mode | Minimum | Maximum | Sample size |
| :----------------------- | --------------------: | ------: | --------: | -----: | ---: | ------: | ------: | ----------: |
| large number of users    |                       |         |           |        |      |         |         |             |
| moderate number of users |                       |         |           |        |      |         |         |             |
| small number of users    |                       |         |           |        |      |         |         |             |

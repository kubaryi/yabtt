# Benchmark :100:

We used [Benchee](https://github.com/bencheeorg/benchee) as a framework to write a simple, (possibly) unscientific Benchmark.

## Defense

We pair **_`100` users_**, **_`1,000` users_** and **_`10,000` users_** with **_`100` BitTorrents_**, **_`1,000` BitTorrents_** and **_`10,000` BitTorrents_** one by one to form a **`3` &#215; `3` matrix**, and obtained a total of `9` groups of cases. Then use functions to randomly generate `Request` based on cases in each run to **imitate the performance of users of different sizes in accessing the server in different numbers of BitTorrents lists**.

```txt
      BitTorrent    BitTorrent     BitTorrent
User (100,   100)  (100,   1000)  (100,   10000)      Randomly generate `Request`
User (1000,  100)  (1000,  1000)  (1000,  10000)   -------------------------------->   &Benchee.run/2
User (10000, 100)  (10000, 1000)  (10000, 10000)
```

## Report

<details>
  <summary><b>System info</b></summary>
    <ul>
      <li>Elixir Version: 1.14.2</li>
      <li>Erlang Version: 25.2</li>
      <li>Operating system: Linux</li>
      <li>Available memory: 6.78 GB</li>
      <li>CPU Information: Intel(R) Xeon(R) Platinum 8272CL CPU @ 2.60GHz</li>
      <li>Number of Available Cores: 2</li>
    </ul>
</details>

<details>
  <summary><b>Environment variables</b></summary>
    <ul>
      <li>YABTT_QUERY_LIMIT: 30</li>
    </ul>
</details>

<details>
  <summary><b>Benchmark configuration</b></summary>
    <ul>
      <li>warmup: 2 s</li>
      <li>time: 5 s</li>
      <li>memory time: 0 ns</li>
      <li>reduction time: 0 ns</li>
      <li>reduction time: 0 ns</li>
      <li>parallel: 1</li>
    </ul>
</details>

### Large number of BitTorrents

| Name                     | Iterations per Second | Average |    Deviation |  Median |                                        Mode | Minimum |  Maximum | Sample size |
| :----------------------- | --------------------: | ------: | -----------: | ------: | ------------------------------------------: | ------: | -------: | ----------: |
| large number of users    |                428.75 | 2.33 ms | &#177;30.50% | 2.23 ms | 2.02 ms, 2.38 ms, 2.17 ms, 2.32 ms, 1.86 ms | 1.63 ms | 12.90 ms |        2141 |
| moderate number of users |                277.75 | 3.60 ms | &#177;16.18% | 3.52 ms |                                     3.28 ms | 3.28 ms | 13.35 ms |        1388 |
| small number of users    |                258.36 | 3.87 ms | &#177;16.59% | 3.77 ms |                            3.75 ms, 3.69 ms | 3.32 ms | 13.42 ms |        1291 |

<p align="center">
  <img alt="plot-1-1" src="https://user-images.githubusercontent.com/26341224/209720658-f6ac98ad-3f1b-49e7-be29-10465c71048c.png" />
</p>

<p align="center">
  <img alt="plot-1-2" src="https://user-images.githubusercontent.com/26341224/209720815-b973ff88-bdc8-46f9-9459-b31fb07ac0f3.png" />
</p>

### Medium number of BitTorrents

| Name                     | Iterations per Second | Average |    Deviation |  Median |                                                          Mode | Minimum |  Maximum | Sample size |
| :----------------------- | --------------------: | ------: | -----------: | ------: | ------------------------------------------------------------: | ------: | -------: | ----------: |
| large number of users    |                353.14 | 2.83 ms | &#177;23.33% | 2.72 ms | 2.65 ms, 2.54 ms, 2.67 ms, 2.52 ms, 2.57 ms, 2.56 ms, 3.04 ms | 2.31 ms | 12.73 ms |        1764 |
| moderate number of users |                268.32 | 3.73 ms | &#177;17.74% | 3.57 ms |                            3.57 ms, 3.50 ms, 3.52 ms, 3.57 ms | 3.14 ms | 11.82 ms |        1341 |
| small number of users    |                255.19 | 3.92 ms | &#177;20.15% | 3.76 ms |                                              3.82 ms, 3.57 ms | 3.27 ms | 18.86 ms |        1275 |

<p align="center">
  <img alt="plot-2-1" src="https://user-images.githubusercontent.com/26341224/209720892-59d1f812-2da9-497e-b3e5-3905c1ef2283.png" />
</p>

<p align="center">
  <img alt="plot-2-2" src="https://user-images.githubusercontent.com/26341224/209720899-cd29a0e1-1224-449d-a702-721e636fbbca.png" />
</p>

### Small amount of BitTorrent

| Name                     | Iterations per Second | Average |    Deviation |  Median |                                                                                                                                                                                                                                              Mode | Minimum |  Maximum | Sample size |
| :----------------------- | --------------------: | ------: | -----------: | ------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | ------: | -------: | ----------: |
| large number of users    |                296.44 | 3.37 ms | &#177;24.14% | 3.15 ms |                                                                                                                                                                                                       3.13 ms, 2.95 ms, 2.92 ms, 3.06 ms, 3.17 ms | 2.70 ms | 12.98 ms |        1481 |
| moderate number of users |                247.43 | 4.04 ms | &#177;18.74% | 3.82 ms |                                                                                                                                                                                                                                           3.95 ms | 3.41 ms | 12.91 ms |        1236 |
| small number of users    |                217.35 | 4.60 ms | &#177;15.88% | 4.48 ms | 4.10 ms, 4.46 ms, 4.41 ms, 4.46 ms, 4.59 ms, 4.28 ms, 4.47 ms, 3.82 ms, 4.45 ms, 4.43 ms, 4.58 ms, 4.06 ms, 4.33 ms, 4.13 ms, 4.43 ms, 4.53 ms, 4.53 ms, 4.07 ms, 4.44 ms, 4.07 ms, 4.56 ms, 4.50 ms, 4.45 ms, 4.56 ms, 4.52 ms, 4.68 ms, 4.38 ms | 3.57 ms | 13.24 ms |        1086 |

<p align="center">
  <img alt="plot-3-1" src="https://user-images.githubusercontent.com/26341224/209720956-2d42eac5-238b-48ba-843a-3f731c0e4980.png" />
</p>

<p align="center">
  <img alt="plot-3-2" src="https://user-images.githubusercontent.com/26341224/209720969-3fff6f04-e04f-4d72-b095-66d8ab736ca5.png" />
</p>

> **Note** This report applies to application version [0.0.1-10d9652](https://github.com/mogeko/yabtt/tree/10d96529ae45f3f4c5aef8a16659085cee89a84a).

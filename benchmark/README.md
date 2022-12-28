# Benchmark :100:

We used [Benchee](https://github.com/bencheeorg/benchee) as a framework to write a simple, (possibly) unscientific Benchmark.

## Defense

We pair **_`100` users_**, **_`1,000` users_** and **_`10,000` users_** with **_`100` BitTorrents_**, **_`1,000` BitTorrents_** and **_`10,000` BitTorrents_** one by one to form a **`3` &#215; `3` matrix**, and obtained a total of `9` groups of cases. Then use functions to randomly generate `Request` based on cases in each run to **imitate the performance of users of different sizes in accessing the server in different numbers of BitTorrents lists**.

```plaintext
     BitTorrent   BitTorrent    BitTorrent
User (100, 100)   (1000, 100)   (10000, 100)       Randomly generate `Request`
User (100, 1000)  (1000, 1000)  (10000, 1000)   -------------------------------->   &Benchee.run/2
User (100, 10000) (1000, 10000) (10000, 10000)
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

| Name                     | Iterations per Second | Average |    Deviation |  Median |             Mode | Minimum |  Maximum | Sample size |
| :----------------------- | --------------------: | ------: | -----------: | ------: | ---------------: | ------: | -------: | ----------: |
| large number of users    |                420.77 | 2.38 ms | &#177;39.32% | 2.32 ms |          2.29 ms | 1.58 ms | 34.68 ms |        2102 |
| moderate number of users |                286.17 | 3.49 ms | &#177;12.64% | 3.45 ms | 3.51 ms, 3.40 ms | 3.03 ms | 10.30 ms |        1430 |
| small number of users    |                259.22 | 3.86 ms | &#177;11.71% | 3.80 ms |          3.86 ms | 3.46 ms | 10.26 ms |        1296 |

<p align="center">
  <img alt="ips-1" src="https://user-images.githubusercontent.com/26341224/209880942-3a9a7417-f178-4b65-b602-4e225fa1ba6a.png" />
</p>

<p align="center">
  <img alt="run-time-1" src="https://user-images.githubusercontent.com/26341224/209881097-791e833b-41d2-4059-8e8e-d9709497d40d.png" />
</p>

### Medium number of BitTorrents

| Name                     | Iterations per Second | Average |    Deviation |  Median |                                                                   Mode | Minimum |  Maximum | Sample size |
| :----------------------- | --------------------: | ------: | -----------: | ------: | ---------------------------------------------------------------------: | ------: | -------: | ----------: |
| large number of users    |                373.84 | 2.67 ms | &#177;17.26% | 2.64 ms |                                                                2.68 ms | 2.26 ms | 10.50 ms |        1868 |
| moderate number of users |                285.58 | 3.50 ms | &#177;17.36% | 3.40 ms |                                                       3.36 ms, 3.33 ms | 3.18 ms | 19.07 ms |        1427 |
| small number of users    |                266.25 | 3.76 ms | &#177;10.83% | 3.69 ms | 3.59 ms, 3.68 ms, 3.56 ms, 3.75 ms, 3.68 ms, 3.62 ms, 3.69 ms, 3.86 ms | 3.42 ms | 10.12 ms |        1331 |

<p align="center">
  <img alt="ips-2" src="https://user-images.githubusercontent.com/26341224/209881104-b5f0e4f9-395b-4013-a5ca-34d9a3e64234.png" />
</p>

<p align="center">
  <img alt="run-time-2" src="https://user-images.githubusercontent.com/26341224/209881109-0e43e649-aea5-4e99-9765-b48a5009530e.png" />
</p>

### Small amount of BitTorrent

| Name                     | Iterations per Second | Average |    Deviation |  Median |             Mode | Minimum |  Maximum | Sample size |
| :----------------------- | --------------------: | ------: | -----------: | ------: | ---------------: | ------: | -------: | ----------: |
| large number of users    |                302.72 | 3.30 ms | &#177;21.15% | 3.14 ms |          2.94 ms | 2.76 ms | 11.55 ms |        1513 |
| moderate number of users |                244.74 | 4.09 ms | &#177;17.88% | 3.77 ms | 3.63 ms, 3.73 ms | 3.41 ms | 11.29 ms |        1223 |
| small number of users    |                232.90 | 4.29 ms | &#177;14.27% | 4.06 ms |          4.02 ms | 3.75 ms | 11.66 ms |        1164 |

<p align="center">
  <img alt="ips-3" src="https://user-images.githubusercontent.com/26341224/209881112-49e268e0-701a-41f0-a2e9-a7901793855f.png" />
</p>

<p align="center">
  <img alt="run-time-3" src="https://user-images.githubusercontent.com/26341224/209881130-ec140571-80c6-4ef1-8e1f-427f408da8f6.png" />
</p>

> **Note** This report applies to application version [0.0.2](https://github.com/mogeko/yabtt/tree/3c7d18ef2feb17a83863f05db3516a4741a43264).

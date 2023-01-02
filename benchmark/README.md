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

| Name                     | Iterations per Second |   Average |    Deviation |    Median |      Mode |   Minimum |    Maximum | Sample size |
| :----------------------- | --------------------: | --------: | -----------: | --------: | --------: | --------: | ---------: | ----------: |
| large number of users    |                1.72 K | 582.96 μs | &#177;27.49% | 552.71 μs | 596.81 μs | 400.40 μs | 4633.06 μs |        8538 |
| moderate number of users |                1.65 K | 605.59 μs | &#177;24.56% | 578.81 μs | 580.51 μs | 428.81 μs | 3176.24 μs |        8217 |
| small number of users    |                1.29 K | 778.12 μs | &#177;21.27% | 754.21 μs | 738.31 μs | 559.91 μs | 7299.99 μs |        6401 |

<p align="center">
  <img alt="ips-1" src="https://user-images.githubusercontent.com/26341224/210267012-c72a9ef0-3ef9-4b33-a1ea-a5278f5b9723.png" />
</p>

<p align="center">
  <img alt="run-time-1" src="https://user-images.githubusercontent.com/26341224/210267019-31772714-8e0a-44bf-8e86-c9fad3077565.png" />
</p>

### Medium number of BitTorrents

| Name                     | Iterations per Second |   Average |    Deviation |    Median |                            Mode |   Minimum |    Maximum | Sample size |
| :----------------------- | --------------------: | --------: | -----------: | --------: | ------------------------------: | --------: | ---------: | ----------: |
| large number of users    |                2.02 K | 496.19 μs | &#177;51.80% | 453.61 μs |                       417.81 μs | 338.10 μs | 6050.87 μs |       10025 |
| moderate number of users |                1.98 K | 504.01 μs | &#177;44.65% | 466.61 μs |                       489.61 μs | 340.20 μs | 8004.10 μs |        9868 |
| small number of users    |                1.73 K | 579.61 μs | &#177;31.73% | 550.01 μs | 578.81 μs, 564.11 μs, 489.81 μs | 402.31 μs | 7547.19 μs |        8582 |

<p align="center">
  <img alt="ips-2" src="https://user-images.githubusercontent.com/26341224/210267022-a101f868-d46a-4251-ae16-5cec40700dca.png" />
</p>

<p align="center">
  <img alt="run-time-2" src="https://user-images.githubusercontent.com/26341224/210267024-94c4a8c1-6425-4bd9-aff8-17d9e76bcfb3.png" />
</p>

### Small amount of BitTorrent

| Name                     | Iterations per Second |   Average |    Deviation |    Median |                 Mode |   Minimum |    Maximum | Sample size |
| :----------------------- | --------------------: | --------: | -----------: | --------: | -------------------: | --------: | ---------: | ----------: |
| large number of users    |                2.05 K | 486.93 μs | &#177;56.65% | 444.46 μs | 429.50 μs, 426.70 μs | 334.80 μs | 6671.58 μs |       10224 |
| moderate number of users |                2.04 K | 490.53 μs | &#177;61.02% | 440.71 μs |            495.41 μs | 327.50 μs | 6818.58 μs |       10141 |
| small number of users    |                1.79 K | 558.13 μs | &#177;29.64% | 531.81 μs |            506.21 μs | 380.81 μs | 3037.14 μs |        8912 |

<p align="center">
  <img alt="ips-3" src="https://user-images.githubusercontent.com/26341224/210267026-94729cce-b414-4463-b2df-a6f6ee1042d7.png" />
</p>

<p align="center">
  <img alt="run-time-3" src="https://user-images.githubusercontent.com/26341224/210267030-e0a18cca-22ce-4605-b233-9f2ead3c3542.png" />
</p>

> **Note** This report applies to application version [0.0.5](https://github.com/mogeko/yabtt/tree/711f6534e56abba51dbec86dc5c2ba714e37bc5b).

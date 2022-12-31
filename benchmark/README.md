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

| Name                     | Iterations per Second |   Average |    Deviation |    Median |                 Mode |   Minimum |     Maximum | Sample size |
| :----------------------- | --------------------: | --------: | -----------: | --------: | -------------------: | --------: | ----------: | ----------: |
| large number of users    |                1.53 K | 652.99 μs | &#177;33.85% | 628.70 μs | 645.40 μs, 635.70 μs | 419.50 μs |  5584.01 μs |        7617 |
| moderate number of users |                1.50 K | 664.84 μs | &#177;37.05% | 629.50 μs |            535.00 μs | 409.90 μs |  7383.41 μs |        7480 |
| small number of users    |                1.01 K | 991.33 μs | &#177;29.80% | 940.79 μs | 824.90 μs, 897.60 μs | 671.00 μs | 10153.44 μs |        5025 |

<p align="center">
  <img alt="ips-1" src="https://user-images.githubusercontent.com/26341224/210154096-1596d17e-5522-4fd8-b933-cfc4e8871ec0.png" />
</p>

<p align="center">
  <img alt="run-time-1" src="https://user-images.githubusercontent.com/26341224/210154101-a9ba660d-1973-47a6-849c-099887c70f2a.png" />
</p>

### Medium number of BitTorrents

| Name                     | Iterations per Second |   Average |    Deviation |    Median |                                       Mode |   Minimum |     Maximum | Sample size |
| :----------------------- | --------------------: | --------: | -----------: | --------: | -----------------------------------------: | --------: | ----------: | ----------: |
| large number of users    |                1.88 K | 531.61 μs | &#177;37.47% | 485.50 μs |                                  493.90 μs | 346.30 μs |  5613.71 μs |        9349 |
| moderate number of users |                1.87 K | 533.89 μs | &#177;47.34% | 488.80 μs |    443 μs, 491.70 μs, 417.20 μs, 440.20 μs | 345.90 μs |  8931.21 μs |        9307 |
| small number of users    |                1.32 K | 755.99 μs | &#177;61.85% | 706.20 μs | 634.60 μs, 702.00 μs, 832.80 μs, 691.80 μs | 518.50 μs | 33562.44 μs |        6582 |

<p align="center">
  <img alt="ips-2" src="https://user-images.githubusercontent.com/26341224/210154103-b17fe2cd-0edc-4203-b5b1-51c59e452a7c.png" />
</p>

<p align="center">
  <img alt="run-time-2" src="https://user-images.githubusercontent.com/26341224/210154104-b7940c6d-a47d-4d11-8e50-c21b27fa0b15.png" />
</p>

### Small amount of BitTorrent

| Name                     | Iterations per Second |   Average |    Deviation |    Median |                                                                                                                 Mode |   Minimum |    Maximum | Sample size |
| :----------------------- | --------------------: | --------: | -----------: | --------: | -------------------------------------------------------------------------------------------------------------------: | --------: | ---------: | ----------: |
| large number of users    |                1.91 K | 524.12 μs | &#177;42.72% | 480.50 μs | 445.70 μs, 502.80 μs, 491.60 μs, 489.80 μs, 449.40 μs, 368.30 μs, 498.50 μs, 447 μs, 503.10 μs, 438.20 μs, 498.70 μs | 339.50 μs | 6138.81 μs |        9480 |
| moderate number of users |                1.83 K | 547.28 μs | &#177;52.97% | 480.50 μs |                                                                                                            483.80 μs | 345.40 μs | 6824.51 μs |        9082 |
| small number of users    |                1.34 K | 744.98 μs | &#177;31.50% | 707.30 μs |                                                                                                            639.90 μs |    517 μs | 6809.51 μs |        6680 |

<p align="center">
  <img alt="ips-3" src="https://user-images.githubusercontent.com/26341224/210154105-69e20e36-5401-4e8a-8afe-04f068396ac1.png" />
</p>

<p align="center">
  <img alt="run-time-3" src="https://user-images.githubusercontent.com/26341224/210154097-01cbe9c5-7832-4b02-b5fb-1d712304bf6f.png" />
</p>

> **Note** This report applies to application version [0.0.4](https://github.com/mogeko/yabtt/tree/a69b9ef10256091b58abf17b8b0147e5cca37332).

# AGQR Recorder

某ラジオを録画するやつ。
Dockerでも利用可。

## 使い方

### Dockerを使用する場合

```sh
# 設定ファイルを格納するディレクトリ、録音したファイルを格納するディレクトリを作成する
$ cd ~
$ mkdir -p agqr/{config,recorded}

# Dockerイメージを落としてくる
$ docker pull zrnns/agqr-recorder

# Dockerイメージを起動する
# - 先程作成した2つのディレクトリをバインドする
$ docker run -it -v ~/agqr/config:/agqr-recorder-data/config -v ~/agqr/recorded:/agqr-recorder-data/recorded zrnns/agqr-recorder

# configディレクトリに設定ファイルが生成されるので、任意に録音設定を行う(設定の詳細は後述)
$ vim ~/agqr/config/config.yaml

# config.yamlで設定した時刻になると、recordedディレクトリ以下に録音したファイルが格納される
$ ls ~/agqr/recorded/
```

### 設定ファイル（config.yaml）の記述方法について

名前は `config.yaml` とする。

```yaml
agqr_stream_url: https://hogehoge/fugafuga.m3u8 # hlsライブストリームのパス
schedules:
  - title: "テスト"       # 番組名（日本語使用可） 
    identifier: "test"  # 番組のID（ローマ字で設定。録音されたファイルは、この名前のサブディレクトリ以下に配置される） 
    weekday: Sun        # 曜日（Sun, Mon, Tue, Wed, Thu, Fri, Satのいずれかを設定。複数指定不可）
    time: "21:00"       # 録音開始時刻
    length_minutes: 30  # 番組の長さ（分）
    thumb_file_name: "default.png"　# アートワークファイル名。config/thumbsディレクトリにこの名前の画像を置いておくと、アートワークを設定してくれる。pngもしくはjpg形式を使用可能。
    artist_name: "artist" # 出演者名
    
  - title: "テスト"       # 録音スケジュールは複数設定可能
    ...
    
```

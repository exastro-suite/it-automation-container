# Exastro IT Automationのコンテナの運用

本ドキュメントでは、コンテナ技術を利用してExastro IT Automationの運用を行うための、考え方と手順を解説します。
コンテナの運用形態は、大きく分けると次の2パターンになります。

  1. DockerやPodman等のコンテナランタイムを直接利用
  1. KubernetesやOpenShift等のPaaSを利用

本ドキュメントでは、前者の直接コンテナランタイムを利用する運用形態にフォーカスしています。
そのため、後者は説明の範疇外です。


# 1. まずは起動してみましょう

Exastro IT Automationのコンテナイメージは、[DockerHubで公開](https://hub.docker.com/r/exastro/it-automation)しており、誰でも利用することができます。
そのため、DockerやPodman等のコンテナランタイムさえあれば、特別な準備をすることなく簡単にExastro IT Automationを起動することができます。
コンテナランタイムのインストール事前にインストールして下さい。

では、さっそくコンテナ化されたExastro IT Automationを起動してみます。コンテナランタイムがインストールされているLinuxマシンにログインし、以下のコマンドを実行してください。  
※podmanコマンドを使用する場合は、dockerの部分をpodmanに置き換えて実施可能です。(一部オプションの指定方法が異なる場合があります)  

```
# docker run \
    --name it-automation \
    --privileged \
    --add-host=exastro-it-automation:127.0.0.1 \
    -d \
    -p 8080:80 \
    -p 10443:443 \
    exastro/it-automation:1.8.0-ja
```

これでExastro IT Automationの起動が完了しました。
次に、Webブラウザのアドレスバーに `http://localhost:8080/` と入力して、Exastro IT Automationにアクセスしてみます。
以下の画面が表示されれば、アクセスは成功です。
なお、コンテナを起動したマシンとは別のマシンでWebブラウザを立ち上げた場合は、`localhost` の部分を適切なホスト名に変更してアクセスしてください。

![ログイン画面](https://qiita-user-contents.imgix.net/https%3A%2F%2Fqiita-image-store.s3.ap-northeast-1.amazonaws.com%2F0%2F652376%2Ff25bcff6-d7f0-bd0f-d62b-a5c24f4a2795.png?ixlib=rb-4.0.0&auto=format&gif-q=60&q=75&w=1400&fit=max&s=403cb8689a5d7b58cb6503ba785b4944)


# 2. プロダクション環境に向けて

前節ではExastro IT Automationのコンテナが簡単に起動できることを示しました。
しかしながら、プロダクション環境においては、要件に合わせて以下のような追加の考慮が必要になります。

  * データの永続化
  * Systemdによるサービス化
  * TLS (SSL) への対応
  * Docker Composeの活用

以降の節では、これらの詳細を説明していきます。

※「1. まずは起動してみましょう」を実施済みで、コンテナを再作成する場合は、同じポート番号、コンテナ名は、使用出来ません。作成済みのコンテナを削除するか、異なるポート番号、コンテナ名を指定して下さい。  
※【】は、適宜任意の名称に読み替えて下さい。  
※ITA1.8.0より前のバージョンは、参考の「マウントポイントの単純化」、バインドマウント時のファイル自動コピー機能は、対応しておりません。

# 3. データの永続化

アップデート等を目的として、コンテナを削除して再作成するのは、よくある作業のひとつです。
しかしながら、コンテナを削除するとコンテナ内に保存されていたデータも削除されてしまうため、注意が必要です。
コンテナを削除した後もデータを残しておきたい場合は、対象データをコンテナ外に保存(データの永続化)する必要があります。

データをコンテナ外に永続化する方法は、以下の2つあります。
  
  * ボリュームを利用
  * バインドマウントを利用
  
ここでは、Exastro IT Automationが利用するデータについて、上記2つの方法でコンテナ外に永続化する方法について記載します。

## 3.1 Exastro IT Automationのデータの保存場所

コンテナ版のExastro IT Automation Ver.1.8.0以降では、データの保存場所を以下の2か所に集約しています。

| パス                     | 説明                                                                                              |
| ------------------------ | ------------------------------------------------------------------------------------------------- |
| /exastro-file-volume     | Exastroが管理するデータファイルを保存。具体的には、作成したメニューや、アップロードしたファイル等 |
| /exastro-database-volume | MariaDBのデータベースファイルを保存                                                               |

この2か所に対して、ボリュームをマウントしたり、バインドマウントしたりすることで、データを永続化することができます。


## 3.2 ボリュームを利用した永続化

Dockerには「ボリューム(volume)」と呼ばれる、データを保存する領域を管理する機能があります。
ボリュームはコンテナとは独立して作成と削除が可能であり、そのためコンテナを削除した後でもデータを残しておくことができます。

ここでは、データファイルの保存先として`exastro-file`という名前のボリュームを、またMariaDBのデータベースファイルの保存先として`exastro-database`という名前の、2つのボリュームを利用する例を示します。

まずは、以下のコマンドを実行してボリュームを作成します。

```
$ docker volume create --name exastro-database
$ docker volume create --name exastro-file
```

次に、コンテナの起動オプションに`--volume`を指定して、ボリュームをコンテナのファイルシステムにマウントします。
以下のコマンドは、ボリューム`exastro-file`をコンテナ内の`/exastro-file-volume`に、またボリューム`exastro-database`をコンテナ内の`/exastro-database-volume`にマウントした状態でコンテナを起動する例です。

```
$ docker run \
    --name it-automation \
    --privileged \
    --add-host=exastro-it-automation:127.0.0.1 \
    --volume exastro-file:/exastro-file-volume \
    --volume exastro-database:/exastro-database-volume \
    -d \
    -p 8080:80 \
    -p 10443:443 \
    exastro/it-automation:1.8.0-ja
```

この時、dockerが「新規に作成されたボリュームの初回利用」であると検知した場合は、マウント先にもともと存在していたファイルは、マウントするボリュームに自動的にコピーされます。
従って、特段の追加作業なしに、ボリュームを利用することができます。


## 3.3 バインドマウントの利用

バインドマウントは、ホストマシンのディレクトリを直接コンテナにマウントする方法です。
ここでは、データファイルの保存先として`/exastro-file`というディレクトリを、またMariaDBのデータベースファイルの保存先として` /exastro-database`というディレクトリを利用する例を示します。

事前準備として、以下のコマンドを実行して、バインドマウントするディレクトリをホストマシン上に作成しておきます。

```
$ sudo mkdir -m 777 /exastro-file
$ sudo mkdir -m 777 /exastro-database
```

次に、コンテナの起動オプションに`--volume`を指定して、ホストマシン上のディレクトリをコンテナのファイルシステムにマウントします。
以下のコマンドは、ホストマシン上のディレクトリ`/exastro-file`をコンテナ内の`/exastro-file-volume`に、またホストマシン上のディレクトリ`/exastro-database`をコンテナ内の`/exastro-database-volume`にマウントした状態でコンテナを起動する例です。

```
$ docker run \
    --name it-automation \
    --privileged \
    --add-host=exastro-it-automation:127.0.0.1 \
    --volume /exastro-file:/exastro-file-volume \
    --env EXASTRO_AUTO_FILE_VOLUME_INIT=true \
    --volume /exastro-database/database:/exastro-database-volume  \
    --env EXASTRO_AUTO_DATABASE_VOLUME_INIT=true \
    -d \
    -p 8080:80 \
    -p 10443:443 \
    exastro/it-automation:1.8.0-ja
```

ここで注意点ですが、ボリュームのマウントとは異なり、バインドマウントの場合はdocker自体にはマウント先のファイルをマウント元に自動的にコピーする機能がありません。
そのため、Exastro IT Automationのコンテナイメージには、マウントされたディレクトリの初回利用時にそのディレクトリを初期化する機能が実装されています。
この機能をdockerのファイルコピー機能の代替として利用できます。

この機能を利用するには、以下の2つの環境変数を設定してExastro IT Automationのコンテナを起動します。

| 環境変数名                          | 既定値  | 説明                                                                                                         |
| ----------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------ |
| `EXASTRO_AUTO_FILE_VOLUME_INIT`     | `false` | `true`の場合は初回のバインドマウント時に`/exastro-file-volume`を初期化する。`false`の場合は初期化しない。    |
| `EXASTRO_AUTO_DATABASE_VOLUME_INIT` | `false` | `true`の場合は初回のバインドマウント時に`/exastro-database-volume`を初期化する。`false`の場合は初期化しない。|

先に示したコンテナの実行例では、これらの環境変数を`true`に設定することで、ファイルの自動コピーを行っています。

なおこの機能は、コンテナ内のディレクトリ`/exastro-file-volume`および`/exastro-database-volume`に`.initialized`というマーカーファイルが存在するかどうかで、初回利用時かどうかを判断しています。
そのため、ファイル`.initialized`は削除しないでください。


# 4. Systemdによるサービス化

コンテナをサービスに登録し、systemctlでコンテナの作成、起動、停止を制御する方法を記載します。

systemdで、コンテナ作成、起動、停止(削除)を制御する場合  
  - ユニットファイルを作成する。  
    ※systemdに登録するコンテナが未作成であること。

```
    # vi /etc/systemd/system/【サービス名】.service  
```

【サービス名】.serviceの記述例

```
[Unit]
 Description=【サービスの説明】
 Requires=docker.service
 After=docker.service

[Service]
 Restart=always
 ExecStart=/usr/bin/docker run \
             --rm \
             --privileged \
             --add-host=exastro-it-automation:127.0.0.1 \
              -d \
              -p 8080:80 \
              -p 10443:443 \
              --name exastro01 \
              exastro/it-automation:1.8.0-ja
 ExecStop=/usr/bin/docker stop exastro01
 RemainAfterExit=yes
[Install]
 WantedBy=default.target
```

- 設定を読み込む。  
```
  # systemctl daemon-reload
```
     
- dockerコンテナの作成、起動  
```
  # systemctl start 【サービス名】.service
```

- dockerコンテナの停止(削除)  
  ※--rmオプションを指定している為、停止の際にコンテナは、削除されます。
```
  # systemctl stop 【サービス名】.service
```

systemdで、コンテナ起動、停止を制御する場合  
- ユニットファイルを作成する。  
  ※systemdに登録するコンテナが作成済みであること。  

```
  # vi /etc/systemd/system/【サービス名】.service
```

【サービス名】.serviceの記述例

```
[Unit]  
 Description=【サービスの説明】
 Requires=docker.service  
 After=docker.service  

[Service]  
 Restart=always  
 ExecStart=/usr/bin/docker start exastro01  
 ExecStop=/usr/bin/docker stop exastro01  
 RemainAfterExit=yes  
[Install]  
 WantedBy=default.target  
```

- 設定を読み込む。  
```
  # systemctl daemon-reload
```
        
- dockerコンテナの開始  
```
  # systemctl start 【サービス名】.service
```

- dockerコンテナの停止  
```
  # systemctl stop 【サービス名】.service
```

# 5. TLS (SSL) への対応

ITAのデフォルトで使用している自己証明書ではなく、独自に用意した証明書を使用する場合は、/etc/pki/tls/certs/に(証明書名).csr、(証明書名).keyを格納して下さい。詳細な手順については、下記URLの、【別紙】ITA-サーバ分散型HA構成インストールマニュアル_8_(Web・AP).pdf→「Apacheの設定」を参照。  
※本手順は、コンテナにログイン後、実施する。  
※手順書には、自己証明書を作成する手順を示しますが、認証局で発行された証明書を使用または、httpの使用で証明書なしの利用も可能です。

  - コンテナにログインする。  
    ※exastro01(コンテナ名)は、適宜読み替える。  
```
    # docker exec -it exastro01 /bin/bash  
```

マニュアル  https://exastro-suite.github.io/it-automation-docs/learn_ja.html#install_distributed_ha


# 6. Docker Composeの活用

Docker Composeは、`docker-compose.yml`から実行に必要なオプションの情報を読み込むことにより、コンテナを起動します。
Docker Composeを利用することで、毎回複雑な起動オプションを指定する必要がなくなり、簡潔な運用を行うことができます。
以下に、Exastro IT Automationのコンテナに対して、ボリュームを割り当てて起動する`docker-compose.yml`の例を示します。

```
version: "3.8"
services:
  exastro:
    image: exastro/it-automation:1.8.1-ja
    container_name: it-automation
    privileged: true
    extra_hosts:
      - "exastro-it-automation:127.0.0.1"
    ports:
      - "8080:80"
      - "10443:443"
    volumes:
      - exastro-database:/exastro-database-volume
      - exastro-file:/exastro-file-volume

volumes:
  exastro-database:
  exastro-file:
```

上記の`docker-compose.yml`の例では、コンテナ内のマウントポイント`/exastro-database-volume`と`/exastro-file-volume`に、それぞれ`exastro-database`と`exastro-file`というボリュームをマウントすることで、データの永続化を実現しています。

この`docker-compose.yml`を利用してコンテナを実行するためには、以下のコマンドを実行します。

```
# docker-compose up -d
```


# 参考

  - マウントポイントの単純化  

コンテナのビルドの時点で、コンテナ内に以下のシンボリックリンクを作成して、そこに必要なファイルを移動しています。共有ファイルは/exastro-file-volumeに、データベースファイルのファイルは/exastro-database-volumeに集約することで、外部ストレージのマウントポイントを単純化しています。

| リンク元 | リンク先 |
| :--- | :--- |
| /exastro /data_relay_storage/symphony | /exastro-file-volume/data_relay_storage/symphony |
| /exastro /data_relay_storage/conductor |  /exastro-file-volume/data_relay_storage/conductor |
| /exastro /data_relay_storage/ansible_driver |  /exastro-file-volume/data_relay_storage/ansible_driver |
| /exastro /ita_sessions | /exastro-file-volume/ita_sessionsr |
| /exastro /ita-root/temp | /exastro-file-volume/ita-root/temp |
| /exastro /ita-root/uploadfiles  | /exastro-file-volume/ita-root/uploadfiles |
| /exastro /ita-root/webroot/uploadfiles | /exastro-file-volume/ita-root/webroot/uploadfiles |
| /exastro /ita-root/webroot/menus/sheets | /exastro-file-volume/ita-root/webroot/menus/sheets |
| /exastro /ita-root/webroot/menus/users | /exastro-file-volume/ita-root/webroot/menus/users |
| /exastro /ita-root/webconfs/sheets | /exastro-file-volume/ita-root/webconfs/sheets |
| /exastro /ita-root/webconfs/users | /exastro-file-volume/ita-root/webconfs/users |
| /var/lib/mysql | /exastro-database-volume/mysql |

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

コンテナを削除した場合、コンテナ内に保存されていたデータも削除されます。
コンテナを削除した後も、コンテナ内のデータを残したい場合は、対象データをコンテナ外に保存(データの永続化)する必要があります。
その為の手段として、「名前付きボリューム」、「バインドマウント」を使用する方法があります。
今回は、コンテナ作成時にExastro連携で使用するデータをホストOS上に外出し、コンテナを再作成した際に
削除前のデータを継続して利用する方法について記載します。

2.1 名前付きボリュームの利用  
ホストOSのDocker管理領域に名前付きボリュームを作成し、コンテナの特定領域にマウントします。
名前付きボリュームは、コンテナを削除した場合でもデータが保持されます。

  - 名前付きボリュームを作成する。  


  - dockerコマンドの入力例  

```
    # docker volume create --name 【ITAのデータベース用ボリューム名】  
    # docker volume create --name 【ITAのファイル用ボリューム名】
```

  - podmanコマンドの入力例  

```
    # podman volume create  【ITAのデータベース用ボリューム名】  
    # podman volume create  【ITAコンテナのファイル用ボリューム名】
```

  - コンテナ作成、起動し、作成した名前付きボリュームにマウントする。docker run 実施時に、オプション-v 【ホストOSのボリューム】:【コンテナのディレクトリパス】で指定した際に、コンテナのディレクトリパス配下のディレクトリ、ファイルが、ホストOSのボリュームに自動でコピー、マウントされます。  

```
# docker run \
    --name it-automation \
    --privileged \
    --add-host=exastro-it-automation:127.0.0.1 \
    -v 【ITAコンテナのデータベース用ボリューム名】:/exastro-database-volume \
    -v 【ITAコンテナのファイル用ボリューム名】:/exastro-file-volume \
    -d \
    -p 8080:80 \
    -p 10443:443 \
    exastro/it-automation:1.8.0-ja  
```

2.2 バインドマウントの利用  
ホストOS上のファイルやディレクトリをコンテナにマウントします。
「バインドマウント」を使用する場合、ホストマシンのファイルシステムに依存するものとなり、利用可能な特定のディレクトリ構造に従ったものになります。  


  - ITAコンテナ用のバインドマウントするディレクトリを作成する。  

```
  # mkdir -p -m 777 /【任意のパス】/exastro-ita/files  
  # mkdir -p -m 777 /【任意のパス】/exastro-ita/database
```

  - コンテナを起動する。  
  
    - 初回実施の動作  
コンテナ作成、起動、ITA連携データをホストOSのディレクトリにコピーし、作成したディレクトリにバインドマウントします。また、「/【任意のパス】/exastro-ita/database/」、「/【任意のパス】/exastro-ita/files/」の配下に.initialized(初回作成の判定ファイル)が作成されます。  

    - 初回実施後にデータを引き継いで、コンテナを再作成する場合  
2回目以降にコマンドを実施した場合は、.initialized(初回作成の判定ファイル)が存在する為、ITA連携データのマウント先である、ホストOSのディレクトリは、初期化されません。  
また、コマンド実行時に、--envオプションを指定しない場合は、.initialized(初回作成の判定ファイル)の有無に関係なく、初期化されません。  

    - 初回実施後に初期化して、コンテナを再作成する場合  
.initialized(初回作成の判定ファイル)を削除した状態でコマンド(--envオプションを含む)を実施する。  
※必要データが存在する場合は、実施前に退避を行ってください。

```
# docker run \
    --name it-automation \
    --privileged \
    --add-host=exastro-it-automation:127.0.0.1 \
    --volume /【任意のパス】/exastro-ita/files:/exastro-file-volume \
    --env EXASTRO_AUTO_FILE_VOLUME_INIT=true \
    --volume /【任意のパス】/exastro-ita/database:/exastro-database-volume  \
    --env EXASTRO_AUTO_DATABASE_VOLUME_INIT=true \
    -d \
    -p 8080:80 \
    -p 10443:443 \
    exastro/it-automation:1.8.0-ja  
```

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

Docker Composeは、コンテナを定義し実行するDockerアプリケーションのためのツールです。YAMLファイルを使ってアプリケーションサービスの設定をすることが可能です。コマンドを１つ実行するだけで、設定内容に基づいたアプリケーションサービスの生成、起動することが出来ます。今回は、コンテナを作成、起動、ホストOS側に作成したボリュームにコンテナのITAデータベース、連携ファイル領域をマウントする場合の設定例を記載します。

  - 任意のディレクトリ配下に、docker-compose.ymlを作成する。  
```
    # vi docker-compose.yml  
```

docker-compose.ymlの設定例  

```
version: "3.8"
services:
  exastro:
    image: exastro/it-automation:1.8.0-ja
    container_name: it-automation
    privileged: true
    extra_hosts:
      - "exastro-it-automation:127.0.0.1"
    ports:
      - "8080:80"
      - "10443:443"
    restart: always
    volumes:
      - exastro-database:/exastro-database-volume
      - exastro-file:/exastro-file-volume

volumes:
  exastro-database:
    name: exastro-database-volume
  exastro-file:
    name: exastro-file-volume
```

  - Docker Composeの起動  
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

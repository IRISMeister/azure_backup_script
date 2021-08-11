# azure_backup_script
[こちらのコミュニティ記事](https://jp.community.intersystems.com/node/481771)のIRIS版です。  
Ubuntu 20.04LTS + IRIS 2021.1 で動作確認しています。

元は[こちら](https://github.com/MicrosoftAzureBackup)ですが、そのままでは動作しなかったので、一部修正を加えています。  

> echoやteeなどの標準出力への出力が不可になったようです。シェルの実行が、そこで異常終了してしまいます。  
> sudo -u irismeister も使用不可なようです。

## 前提
IRISがインストールされたVM(Ubuntu)が稼働済みであること。IRISはコミュニティ版でもかまいません。   
> ARMテンプレート使用してIRISをAzureにデプロイする方法は、[こちら](https://github.com/IRISMeister/iris-azure-arm)を参考にしてください。

VMにVMエージェントがインストールされていること。

> 自前でVMイメージを作成しているのでなければ、自動でインストールされます。

## 導入手順
対象のVMにログインし、下記を実行します。

```bash
$ pwd
/home/irismeister
$ git clone https://github.com/IRISMeister/azure_backup_script.git
```

[「Azure Linux VM のアプリケーション整合性バックアップ」](https://docs.microsoft.com/ja-jp/azure/backup/backup-azure-linux-app-consistent)の手順を実行します。

```bash
$ cd azure_backup_script/
$ sudo mkdir /etc/azure
$ sudo cp *.sh /etc/azure/
$ sudo cp VMSnapshotScriptPluginConfig.json /etc/azure/
$ sudo chmod 700 /etc/azure/*.sh
$ sudo chmod 600 /etc/azure/VMSnapshotScriptPluginConfig.json
```

## 実行方法
[「Recovery Services コンテナーに Azure VM をバックアップする」](https://docs.microsoft.com/ja-jp/azure/backup/backup-azure-arm-vms-prepare)の手順を実行します。

Recovery Services vaultを作成します。

![1](https://raw.githubusercontent.com/IRISMeister/doc-images/main/azure_backup_script/1.png)



Recovery Services vaultのメニューでBackupをクリックし、バックアップを構成します。

![2](https://raw.githubusercontent.com/IRISMeister/doc-images/main/azure_backup_script/2.png)



Add VM, Enable backupをクリックして、対象のVMでバックアップを有効化します。

![3](https://raw.githubusercontent.com/IRISMeister/doc-images/main/azure_backup_script/3.png)



Recovery Services vaultのメニューでBackup Itemsをクリックし, さらにAzure Virtual Machineを選択します。

![4](https://raw.githubusercontent.com/IRISMeister/doc-images/main/azure_backup_script/4.png)



先ほど追加したバックアップ項目が表示されているはずです。Backup Statusが下記であることを確認します。

>    Backup Pre-Check: Passed
>    Last backup status: Warning(Initial backup pending)

![5](https://raw.githubusercontent.com/IRISMeister/doc-images/main/azure_backup_script/5.png)



バックアップ項目を選択します。バックアップを直ちに開始させるために、Backup Nowをクリックし、Retain Backup Tillを適当(最短など)に設定してバックアップを開始します。

Recovery Services vaultのメニューでBackup Jobsをクリック、最新のエントリのView Detailsをクリックします。状態を確認し、Take SnapshotがIn ProgressやCompletedになっていることを確認します。

![6](https://raw.githubusercontent.com/IRISMeister/doc-images/main/azure_backup_script/6.png)



バックアップが完了すると、Application Consistentでバックアップされた旨の通知が表示されます。

![7](https://raw.githubusercontent.com/IRISMeister/doc-images/main/azure_backup_script/7.png)


## 動作の確認
バックアップ対象のVMにSSHし、preScript.sh, postScript.shのログを確認します。

```bash
root@MyubuntuVM:/etc/azure# cat /var/tmp/BackupScript.log
08/11/2021 05:49:43: Backup.General.ExternalFreeze: Suspending system
08/11/2021 05:49:43: Backup.General.ExternalFreeze: Warning, /usr/irissys/mgr/irislocaldata/ is not being journalled
08/11/2021 05:49:43: Backup.General.ExternalFreeze: Warning, 1 databases are not journalled, data will be lost in them if system crashes while suspended

Journal file switched to:
/iris/journal1/20210811.003
08/11/2021 05:49:43: Backup.General.ExternalFreeze: Start a journal restore for this backup with journal file: /iris/journal1/20210811.003

Journal marker set at
offset 262272 of /iris/journal1/20210811.003
08/11/2021 05:49:44: Backup.General.ExternalFreeze: System suspended
SYSTEM IS FROZEN
08/11/2021 05:49:54: Backup.General.ExternalThaw: Resuming system
08/11/2021 05:49:55: Backup.General.ExternalThaw: System resumed
SYSTEM IS UNFROZEN
root@MyubuntuVM:/etc/azure#
```

irisのログも確認しておきます。ExternalFreeze(), ExternalThaw()が実行された旨が記録されているはずです。

```bash
root@MyubuntuVM:/etc/azure# tail /usr/irissys/mgr/messages.log
08/11/21-04:38:13:440 (17808) 0 [Database.MountedRW] Mounted database /usr/irissys/mgr/user/ (SFN 5) read-write.
08/11/21-05:49:43:233 (18374) 0 [Utility.Event] Backup.General.ExternalFreeze: Suspending system
08/11/21-05:49:43:233 (18374) 1 [Utility.Event] Backup.General.ExternalFreeze: Warning, /usr/irissys/mgr/irislocaldata/ is not being journalled
08/11/21-05:49:43:233 (18374) 1 [Utility.Event] Backup.General.ExternalFreeze: Warning, 1 databases are not journalled, data will be lost in them if system crashes while suspended
08/11/21-05:49:43:342 (18374) 0 [Generic.Event] INTERSYSTEMS IRIS JOURNALING SYSTEM MESSAGE
Journaling switched to: /iris/journal1/20210811.003
08/11/21-05:49:43:342 (18374) 0 [Utility.Event] Backup.General.ExternalFreeze: Start a journal restore for this backup with journal file: /iris/journal1/20210811.003
08/11/21-05:49:44:347 (18374) 0 [Utility.Event] Backup.General.ExternalFreeze: System suspended
08/11/21-05:49:54:410 (18380) 0 [Utility.Event] Backup.General.ExternalThaw: Resuming system
08/11/21-05:49:55:411 (18380) 0 [Utility.Event] Backup.General.ExternalThaw: System resumed
root@MyubuntuVM:/etc/azure#
```

## リストア手順
最後の画面で、...をクリックして、Restore VMを選択します。適切な値を設定してRestoreをクリックします。

![8](https://raw.githubusercontent.com/IRISMeister/doc-images/main/azure_backup_script/8.png)



Recovery Services vaultのメニューでBackup Jobsで最新のエントリのView Detailsをクリックして状態を確認します。  
Create the restored virtual machineがCompletedになればリストア完了です。

![9](https://raw.githubusercontent.com/IRISMeister/doc-images/main/azure_backup_script/9.png)



作成されたVMにSSHし、IRISのログを確認します。下記のようにSystem suspended直後(Snapshot取得時点)から、今回の起動プロセスのログが記録されているはずです。

```bash
root@MyubuntuVM:/etc/azure# cat /usr/irissys/mgr/messages.log
08/11/21-05:49:44:347 (18374) 0 [Utility.Event] Backup.General.ExternalFreeze: System suspended

*** Recovery started at Wed Aug 11 06:12:30 2021
     Current default directory: /usr/irissys/mgr
     Log file directory: /usr/irissys/mgr/
     WIJ file spec: /iris/wij/IRIS.WIJ
Recovering local (/iris/wij/IRIS.WIJ) image journal file...
Starting WIJ recovery for '/iris/wij/IRIS.WIJ'.
  0 blocks pending in this WIJ.
WIJ pass # is 0.
Starting fast WIJ compare
Finished comparing 11 blocks in 0 seconds
Exiting with status 3 (Success)
08/11/21-06:12:30:224 (1148) 0 [Generic.Event] InterSystems IRIS license file (iris.key) must be validated with License Server.
08/11/21-06:12:30:297 (1148) 0 [Generic.Event] Allocated 430MB shared memory: 128MB global buffers, 128MB routine buffers
08/11/21-06:12:30:308 (1148) 0 [Crypto.IntelSandyBridgeAESNI] Intel Sandy Bridge AES-NI instructions detected.
```


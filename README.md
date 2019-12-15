# Tang Nano design for M5Stack

## 概要

M5StackからTang NanoをI2C経由で制御するためのTang Nanoのデザイン

## 機能

WS2812の制御モジュールを試験的に実装。I2C経由で制御可能。

I2Cのデバイスアドレスは `7'h48`

GW1N-1の45番ピンがSCL、44番ピンがSDA、43番ピンがWS2812のシリアル信号出力

I2Cのレジスタ・マップは次の通り

| オフセット | アクセス | 内容 |
|:---|:---|:---|
| 0x00 | RW | 操作対象のLEDの番号 |
| 0x01 | RW | 現在選択しているLEDの赤色の輝度値 |
| 0x02 | RW | 現在選択しているLEDの緑色の輝度値 |
| 0x03 | RW | 現在選択しているLEDの青色の輝度値 |

## モジュール

### i2c_slave.v

よくあるレジスタ・アクセス用のI2CプロトコルでFPGA内部のレジスタにアクセスするためのコア

### ws2812b.sv

WorldsemiのWS2812Bを制御するためのシリアル信号を生成するモジュール。

## ビルド

GoWin IDEをダウンロードしてどこかのディレクトリ (例：`$HOME/gowin/1.9.2.02` )に展開します。

展開したディレクトリを `$GOWIN_HOME` として、 `$GOWIN_HOME/IDE/bin:$GOWIN_HOME/Programmer/bin` をパスに追加します。

```bash
export PATH=$GOWIN_HOME/IDE/bin:$GOWIN_HOME/Programmer/bin:$PATH
```

ライセンスの設定を行っておきます。参考：[https://qiita.com/ciniml/items/bb9723673c91d8374b63](https://qiita.com/ciniml/items/bb9723673c91d8374b63)

このリポジトリをcloneして、makeでビルドします。

```bash
git clone https://github.com/ciniml/M5Stack_TangNano
cd M5Stack_TangNano
make
```

## 書き込み

とりあえず試したいだけならSRAMコンフィグをします。電源を入れ直せば書き込んだ内容は消えます。

`make run` を実行するとSRAMコンフィグを実行します。

```bash
$ make run
if lsmod | grep ftdi_sio; then sudo modprobe -r ftdi_sio; fi
programmer_cli --device GW1N-1 --run 2 --fsFile M5Stack_TangNano/impl/pnr/M5Stack_TangNano.fs
 "SRAM Program" starting on device-1...
Programming...: [######################## ] 99%                  User Code: 0x00000000
 Status Code: 0x0001F020
 Cost 4.91 second(s)
```

電源を切っても消えないようにコンフィグROMに書き込みたい場合は、`make deploy` を実行します。

```bash
$ make deploy
if lsmod | grep ftdi_sio; then sudo modprobe -r ftdi_sio; fi
programmer_cli --device GW1N-1 --run 6 --fsFile M5Stack_TangNano/impl/pnr/M5Stack_TangNano.fs
 "embFlash Erase,Program,Verify" starting on device-1...
Erasing embFlash ...: [                         ] 0%                 number addresses of data:332
Programming...: [#########################] 100%
Verifying...: [#########################] 100%
 Verify success!
 Status Code: 0x0001F020
 User Code: 0x00000000
 Finished!
 Cost 36.4 second(s)
```

## ライセンス

[Boost Software License](https://www.boost.org/LICENSE_1_0.txt) です。ソースコードにライセンスの文言が残っていればいい、とてもゆるいライセンスです。

コードの内容は一切保証しないし、コードを使って起きたいかなる損害についても補償しません。

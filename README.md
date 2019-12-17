# SERV RISC-V core design for Tang Nano

## 概要

RISC-VのCPUコア `SERV` をTang Nanoで動かすためのデザイン。

## 機能

Lチカします。

`sw/blinky.hex` がSERVで実行されるプログラムになっています。SERVに付属のblinky.hexの定数をデザインに合わせて修正したものです。

5行目の

```
0042c293
```

が、 `xori t0, t0, 4` に対応する命令で、左から3桁が即値の `4` に対応しています。
よって、 `0042c293` を `0012c293` に書き換えると、 `xori t0, t0, 1` になります。

この値はRGB LEDの各色に対応しているので、デフォルトで青色、変更後は赤色が点滅します。`0022c293`だと緑色です。

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

私が書いた部分 (srcディレクトリ以下)は [Boost Software License](https://www.boost.org/LICENSE_1_0.txt) です。ソースコードにライセンスの文言が残っていればいい、とてもゆるいライセンスです。

コードの内容は一切保証しないし、コードを使って起きたいかなる損害についても補償しません。

serv/以下のSERVコアのソースは、SERVのライセンスに従います。

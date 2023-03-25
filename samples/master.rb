# coding: utf-8

#I2C 初期化
i2c = I2C.new(22, 21)

# 時計をストップ．レジスタ 0x00 に 0x20 (00100000) を入力．
# 6 ビット目に 1 を立てると時計がストップする．
# 詳細はデータシートの Table 5, 6 を参照．
#rtc.initialize(i2c)

#WLANの初期化
wlan = WLAN.new('STA', WLAN::ACTIVE)
wlan.connect("SSID", "passwd")

# RTC 初期化用の日時を設定し、初期化する
rtc = PCF85063TP.new(i2c)
idate = Array.new
if wlan.is_connected?
    tt = SNTP.new()
    idate[0] = tt.year2()   # 西暦の下 2 桁
    idate[1] = tt.mon()     # 月
    idate[2] = tt.wday()    # 曜日 (0-6)
    idate[3] = tt.mday()    # 日付
    idate[4] = tt.hour()    # 時
    idate[5] = tt.min()     # 分
    idate[6] = tt.sec()     # 秒
else
    idate[0] = 23   # 西暦の下 2 桁
    idate[1] = 12   # 月
    idate[2] = 6    # 曜日 (0-6)
    idate[3] = 31   # 日付
    idate[4] = 23   # 時
    idate[5] = 59   # 分
    idate[6] = 50   # 秒
end
rtc.write( idate )


loop do

    buf = rtc.read()    # RTC から情報を読み込み
    
    # 日付の表示
    puts "str_date() : #{rtc.str_date}"
    puts "str_time() : #{rtc.str_time}"
    puts "year() : #{rtc.year}"
    puts "year2() : #{rtc.year2}"
    puts "mon() : #{rtc.mon}"
    puts "mday() : #{rtc.mday}"
    puts "wday() : #{rtc.wday}"
    puts "hour() : #{rtc.hour}"
    puts "min() : #{rtc.min}"
    puts "sec() : #{rtc.sec}"

    sleep 1
end

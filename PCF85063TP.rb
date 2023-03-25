# RTC: PCF85063TP
# I2C address : 0x51

class PCF85063TP

    # 時計をストップ. レジスタ 0x00 に 0x20 (8bit : 00100000) を入力.
    # 6 ビット目に 1 を立てると時計がストップする.
    # 詳細はデータシートの Table 5, 6 を参照
    def initialize(i2c)
        @i2c = i2c
        @i2c.writeto(0x51, [0x00, 0x20])
        sleep 0.1
    end
    
    # RTC への書き込み後, 時計をスタート. 引数は数字( 10進数 )の配列
    # 時計をスタート．レジスタ 0x00 に 0x00 (00000000) を入力．
    # 詳細はデータシートの Table 5, 6 を参照
    # 配列 idate [ Years(2桁), Months, Weekdays(曜日), Days, Hours, Minutes, Seconds] : 10進数で格納
    def write( idate )
        date = Array.new # idate配列の内容を16進数で格納
        
        # BCD データへの変換
        i = 0
        idate.each do |num|
          date[i] = (num / 10 * 16) + (num % 10)
          i += 1
        end
        
        # RTC への入力．レジスタ 0x04 から順番に秒，分，... を入力．
        # 10 進数を 16 進数に変換する必要がある．
        @i2c.writeto(0x51, [0x04, date[6], date[5], date[4], date[3], date[2], date[1], date[0] ])
        sleep 0.1
        
        # 時計をスタート
        @i2c.writeto(0x51, [0x00, 0x00])
        sleep 0.1
    end
    
    # RTC からの読み込み. 戻り値は数字の配列 [ Years(2桁), Months, Weekdays(曜日), Days, Hours, Minutes, Seconds] : 10進数で格納
    def read()
        @i2c.writeto(0x51, [0x04])     # レジスタ 0x04 まで進める
        buf = @i2c.readfrom(0x51, 7)   # 7 バイト分読み込み
        
        @time = Array.new
        
        i = 0
        [buf[6], buf[5], buf[4], buf[3], buf[2], buf[1], buf[0] ].each do |num|
            # 16進数を10進数に変換
            @time[i] = (num / 16 * 10) + (num % 16)
            i += 1
        end
        
        return [@time[0].to_i, @time[1].to_i, @time[2].to_i, @time[3].to_i, @time[4].to_i, @time[5].to_i, @time[6].to_i]
    end
    
    # 年月日自分秒の配列を返す
    # [ Years(2桁), Months, Weekdays(曜日), Days, Hours, Minutes, Seconds] : 10進数で格納
    def datetime
        read()
    end
    
    # 文字列で日付を戻す ( yyyy-mm-dd )
    def str_date()
        #read()
        return sprintf("20%02d-%02d-%02d", @time[0], @time[1], @time[3]).to_s
    end
    
    # 文字列で時間を戻す
    def str_time()
        #read()
        return sprintf("%02d:%02d:%02d", @time[4], @time[5], @time[6]).to_s
    end  
    
    # 文字列で日時を戻す
    def str_datetime()
        #read()
        return sprintf("20%02d%02d%02d%02d%02d%02d", @time[0], @time[1], @time[3], @time[4], @time[5], @time[6]).to_s
    end
    
    # 時刻取得
    def year()
    return @time[0].to_i + 2000
    end
    
    def year2()
        return @time[0].to_i
    end
    
    def mon()
        return @time[1].to_i
    end
    
    def wday()
        return @time[2].to_i
    end
    
    def mday()
        return @time[3].to_i
    end
    
    def hour()
        return @time[4].to_i
    end
    
    def min()
        return @time[5].to_i
    end
    
    def sec()
        return @time[6].to_i
    end
end

##| API 파싱
require 'uri'
require 'net/http'
require 'rexml/document'

request = 'http://apis.data.go.kr/1360000/AsosDalyInfoService/getWthrDataList'
service_key = '?serviceKey='
args = '&numOfRows=34&pageNo=1&dataCd=ASOS&dateCd=DAY'
days = '&startDt=20190626&endDt=20190729'
station_id = '&stnIds=108'

uri = URI.parse(request + service_key + args + days + station_id)

req = Net::HTTP.get_response(uri)
doc = REXML::Document.new(req.body)

puts doc

##| 초기 설정
sumRn = [] ## 합계 강수량
minTa = [] ## 최저 온도
maxTa = [] ## 최고 온도
ssDur = [] ## 가조 시간
maxWs = [] ## 최대 풍속
use_random_seed 100

##| 파싱한 데이터를 배열인지 거따 넣기
doc.elements.each('response/body/items/item') {|item|
  elem = item.elements
  sumRn.push(elem['sumRn'].text.to_f)
  minTa.push(elem['minTa'].text.to_f)
  maxTa.push(elem['maxTa'].text.to_f)
  ssDur.push(elem['ssDur'].text.to_f)
  maxWs.push(elem['maxWs'].text.to_f)
}

##| sound
rain = '\rain.wav'

live_loop :rainy do
  for day in 0..33
    sample rain, amp: [45, 10 + sumRn[day]*8].min, attack: 2.0, release: 4.0
    sleep 2
  end
  stop
end

live_loop :tamp do
  with_synth :piano do
    for day in 0..33
      play :b3 + 2*(maxTa[day] - minTa[day]), amp: 8, attack: 1, release: 0.2, cutoff: [20, minTa[day]].min*4
      sleep 2
    end
  end
end

live_loop :ssDur do
  with_synth :pluck do
    for day in 0..33
      2.times do
        play :c2+ssDur[day]*3, release: ssDur[day]/20, amp: 0.6, pan: 1-(day%2)*2, cutoff: [8, ssDur[day]].min*4
        ##| sleep rrand(0, ssDur[day]/20)
        sleep choose([ssDur[day]/100, ssDur[day]/50, ssDur[day]/20, ssDur[day]/25, ssDur[day]/200])
      end
    end
  end
end

live_loop :maxWs do
  with_synth :dtri do
    for day in 0..33
      4.times do
        play :g2+maxWs[day], release: 5, amp: 0.2
        sleep 4
      end
    end
  end
end
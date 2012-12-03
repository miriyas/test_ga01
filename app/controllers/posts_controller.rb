# encoding: utf-8
require 'gattica'

class PostsController < ApplicationController
  def index
    $ga = Gattica.new({ 
        :email => 'miriya.test@gmail.com', 
        :password => 'miriyatest'
    })
    $ga.profile_id = 44131444 

    params[:start_date] = Date.parse(params[:start_date].to_a.collect{|c| c[1]}.join("-")).to_s if params[:start_date].present?
    params[:end_date]   = Date.parse(params[:end_date].to_a.collect{|c| c[1]}.join("-")).to_s if params[:end_date].present?

    # 날짜 값이 넘어오지 않을 경우 임의의 값을 사용.
    $start_date = params[:start_date] || (Time.now+1.month-1.years).to_date.to_formatted_s(:db)    
    $end_date   = params[:end_date]   || (Time.now+1.month-1.days).to_date.to_formatted_s(:db)
    
    # 끝나는 날보다 시작일이 뒤일 경우 강제로 시작일에 1달 더한 날을 끝나는 날로 잡는다.
    $end_date   = ($start_date.to_date+1.month).to_s if $start_date.to_date >= $end_date.to_date


    ####
    def get_monthly_visitors
      datas = $ga.get({ 
        :start_date   => $start_date,
        :end_date     => $end_date,
        :dimensions   => ['year', 'month'],
        :metrics      => ['visitors', 'newVisits', 'bounces']
      }).to_h['points'].to_json
      @datas      = JSON.parse(datas)
      datas_table = GoogleVisualr::DataTable.new

      datas_table.new_column('string', 'Date' )
      datas_table.new_column('number', 'Bounces')
      datas_table.new_column('number', 'new Visitors')
      datas_table.new_column('number', 'Visitors')
      @datas.each do |data|
        datas_table.add_rows([[data["year"]+"년 "+data["month"]+"월", data["bounces"], data["newVisits"], data["visitors"]]])
      end

      option = {
        width: 800, height: 360, chartArea:{left:50, top:50, width:"90%", height:"75%"},
        title: 'Monthly Visitors', titlePosition:'out', titleTextStyle:{color:'white',fontSize:16},
        hAxis: {textStyle:{color:'white', fontSize:11}}, 
        vAxis: {textStyle:{color:'white', fontSize:11}, baselineColor:'#d6d6d6', gridlines: {color: 'black', count: 6}},
        backgroundColor:{fill:'#343555', stroke:'#d6d6d6', strokeWidth:1},
        colors:['#47AAB3','#ECAD55','#644D9C'],
        lineWidth:'3', pointSize:'5', curveType:'function',
        focusTarget:'category',
        legend:{position: 'in', textStyle: {color: 'white', fontSize: 12}},
        animation:{duration: 1000, easing: 'out'}
      }

      @chart_monthly_visitors = GoogleVisualr::Interactive::AreaChart.new(datas_table, option)
    end
    get_monthly_visitors


    ####
    def get_daily_visitors
      datas = $ga.get({ 
        :start_date   => (Time.now-1.months).to_date.to_formatted_s(:db),
        :end_date     => (Time.now-1.days).to_date.to_formatted_s(:db),
        :dimensions   => ['date'],
        :metrics      => ['visitors', 'newVisits', 'bounces', 'pageviews']
      }).to_h['points'].to_json
      @datas      = JSON.parse(datas)
      datas_table = GoogleVisualr::DataTable.new

      # Add Column Headers
      datas_table.new_column('string', 'Date' )
      datas_table.new_column('number', 'Bounces')
      datas_table.new_column('number', 'new Visitors')
      datas_table.new_column('number', 'Visitors')
      datas_table.new_column('number', 'PageViews')
      @datas.each do |data|
        datas_table.add_rows([[data["date"], data["bounces"], data["newVisits"], data["visitors"], data["pageviews"]]])
      end

      option = {
        width: 800, height: 360, chartArea:{left:50, top:50, width:"87%", height:"75%"},
        backgroundColor:{fill:'white', stroke:'#d6d6d6', strokeWidth:1},
        title: 'Daily Visitors & PageViews', titlePosition:'out', titleTextStyle:{color:'black',fontSize:16},
        legend:{position: 'in', textStyle: {color: 'black', fontSize: 12}},
        hAxis: {textStyle:{color:'#666666', fontSize:9}}, 
        vAxes: [
          {minValue:0,textStyle:{color:'black', fontSize:11}, baselineColor:'black', gridlines: {color: '#d6d6d6', count: 6}},
          {minValue:0, textStyle:{color:'d2665a', fontSize:11}, baselineColor:'black', gridlines: {color: '#d6d6d6', count: 6}}
        ],
        series: [
          {targetAxisIndex:0},
          {targetAxisIndex:0},
          {targetAxisIndex:0},
          {targetAxisIndex:1}
        ],
        colors:['#9976c2','#52aadf','#7bbb4b','#d2665a'],
        lineWidth:'2', curveType:'function',
        focusTarget:'category',
        animation:{duration: 1000, easing: 'out'}
      }
      @chart_daily_visitors = GoogleVisualr::Interactive::LineChart.new(datas_table, option)
    end
    get_daily_visitors


    ####
    def get_new_visitors_rate_month
      datas = $ga.get({ 
        :start_date   => $start_date,
        :end_date     => $end_date,
        :dimensions   => ['month'],
        :metrics      => ['newVisits', 'visits']
      }).to_h['points'].to_json
      @datas      = JSON.parse(datas)
      datas_table = GoogleVisualr::DataTable.new

      ## possible bug : 3달 이상 기간 지정할 경우 1,3월만 더해져 잘못 나올 수 있을듯.. 확인 필.
      new_visitor = @datas.first["newVisits"]+@datas.last["newVisits"]
      return_visitor = @datas.first["visits"]+@datas.last["visits"]-new_visitor

      # Add Column Headers
      datas_table.new_column('string', 'month')
      datas_table.new_column('number', 'zzzz')
      datas_table.add_rows([['new', new_visitor]])
      datas_table.add_rows([['return', return_visitor]])

      option = {
        width: 400, height: 360, chartArea:{left:25, top:50, width:"90%", height:"75%"},
        title: 'new Visitors rate of this month', titlePosition:'out', titleTextStyle:{color:'white',fontSize:16},
        hAxis: {textStyle:{color:'white', fontSize:11}}, 
        vAxis: {textStyle:{color:'white', fontSize:11}, baselineColor:'#d6d6d6', gridlines: {color: 'black', count: 6}},
        backgroundColor:{fill:'#343555', stroke:'#d6d6d6', strokeWidth:1},
        colors:['#47AAB3','#ECAD55','#644D9C'],
        lineWidth:'1', curveType:'function',
        focusTarget:'category',
        legend:{position: 'in', textStyle: {color: 'white', fontSize: 12}},
        animation:{duration: 1000, easing: 'out'}
      }
      @chart_new_visitors_rate_month = GoogleVisualr::Interactive::PieChart.new(datas_table, option)
    end
    get_new_visitors_rate_month


    ####
    def get_mobile_visitors_rate_month
      datas = $ga.get({ 
        :start_date   => $start_date,
        :end_date     => $end_date,
        :dimensions   => ['month', 'isMobile'],
        :metrics      => ['visits']
      }).to_h['points'].to_json
      @datas      = JSON.parse(datas)
      datas_table = GoogleVisualr::DataTable.new

      mobile  = 0
      desktop = 0
      @datas.each_index do |index|
        desktop += @datas[index]["visits"].to_int if index.odd?
        mobile += @datas[index]["visits"].to_int if index.even?
      end

      # Add Column Headers
      datas_table.new_column('string', 'visitor')
      datas_table.new_column('number', 'zzzz')
      datas_table.add_rows([['desktop', desktop]])


      option = {
        width: 400, height: 360, chartArea:{left:25, top:50, width:"90%", height:"75%"},
        title: 'mobile Visitors rate of this month', titlePosition:'out', titleTextStyle:{color:'white',fontSize:16},
        hAxis: {textStyle:{color:'white', fontSize:11}}, 
        vAxis: {textStyle:{color:'white', fontSize:11}, baselineColor:'#d6d6d6', gridlines: {color: 'black', count: 6}},
        backgroundColor:{fill:'#343555', stroke:'#d6d6d6', strokeWidth:1},
        colors:['#47AAB3','#ECAD55','#644D9C'],
        lineWidth:'1', curveType:'function',
        focusTarget:'category',
        legend:{position: 'in', textStyle: {color: 'white', fontSize: 12}},
        animation:{duration: 1000, easing: 'out'}
      }
      @chart_mobile_visitors_rate_month = GoogleVisualr::Interactive::PieChart.new(datas_table, option)
    end
    get_mobile_visitors_rate_month
    
    ####
    def get_geo_chart
      datas = $ga.get({ 
        :start_date   => $start_date,
        :end_date     => $end_date,
        :dimensions   => ['country'],
        :metrics      => ['visits', 'pageviewsPerVisit', 'avgTimeOnPage', 'percentNewVisits', 'visitBounceRate'],
        :sort         => ['-visits']
      }).to_h['points'].to_json
      @datas      = JSON.parse(datas)
      $geo_chart  = @datas
      
      datas_table = GoogleVisualr::DataTable.new

      # Add Column Headers
      datas_table.new_column('string', 'Date' )
      datas_table.new_column('number', 'Visits')
      @datas.each do |data|
        datas_table.add_rows([[data["country"], data["visits"]]])
      end


      option = {
        width: 800, height: 640, chartArea:{left:50, top:50, width:"87%", height:"75%"},
        backgroundColor:{fill:'white', stroke:'#d6d6d6', strokeWidth:1},
        title: 'Daily Visitors & PageViews', titlePosition:'out', titleTextStyle:{color:'black',fontSize:16},
        colors:['#9976c2','#52aadf','#7bbb4b','#d2665a']
      }
      @chart_geo_chart = GoogleVisualr::Interactive::GeoChart.new(datas_table, option)
    end
    get_geo_chart
    
  
    ####  왜 이런지 모르겠는데 로딩 더럽게 느림;;
    def get_korea_chart
      datas = $ga.get({ 
        :start_date   => $start_date,
        :end_date     => $end_date,
        :dimensions   => ['region'],
        :metrics      => ['visits']
      }).to_h['points'].to_json
      @datas      = JSON.parse(datas)
      datas_table = GoogleVisualr::DataTable.new

      # Add Column Headers
      datas_table.new_column('string', 'Region' )
      datas_table.new_column('number', 'Visits')
      @datas.each do |data|
        datas_table.add_rows([[data["region"], data["visits"]]])
      end

      option = {
        width: 800, height: 640, chartArea:{left:50, top:50, width:"87%", height:"75%"},
        backgroundColor:{fill:'white', stroke:'#d6d6d6', strokeWidth:1},
        title: 'Daily Visitors & PageViews', titlePosition:'out', titleTextStyle:{color:'black',fontSize:16},
        colors:['#9976c2','#52aadf','#7bbb4b','#d2665a'],
        region: 'KR', resolution: 'provinces', #displayMode: 'markers'
      }
      @chart_korea_chart = GoogleVisualr::Interactive::GeoChart.new(datas_table, option)
    end
    get_korea_chart
  end
end

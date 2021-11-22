#You should not need to modify the code below.  Save this code in a file and include that file wherever needed (i.e. in your refinement that leverages this pop support logic)
view: pop_support {
  derived_table: {
    sql:
      select periods_ago from
      (
        select 0 as periods_ago
        {% if periods_ago._in_query%}{%comment%}extra backstop to prevent unnecessary fannouts if this view gets joined for any reason but periods_ago isn't actually used.{%endcomment%}
        {% for i in (1..52)%} union all select {{i}}{%endfor%}{%comment%}Up to 52 weeks.  Number can be set higher, no real problem except poor selections will cause a pivot so large that rendering will get bogged down{%endcomment%}
        {%endif%}
      ) possible_periods
      where {%condition periods_ago_to_include%}periods_ago{%endcondition%}
      {% if periods_ago_to_include._is_filtered == false%}and periods_ago <=1{%endif%}{%comment%}default to only one prior period{%endcomment%}
      ;;
  }
  dimension: periods_ago {hidden:yes type:number}
  filter: periods_ago_to_include {
    label: "PoP Periods Ago To Include"
    description: "Apply this filter to specify which past periods to compare to. Default: 0 or 1 (meaning 1 period ago and 0 periods ago(current)).  You can also use numeric filtration like Less Than or Equal To 12, etc"
    type: number
    default_value: "0,1"
  }
  dimension: period_label_sql {
    hidden:yes
    expression:
    if(${pop_support.periods_ago}=0," Current"
      , concat(
          ${pop_support.periods_ago}," REPLACE_WITH_PERIOD"
          ,if(${pop_support.periods_ago}>1,"s","")
          ," Prior"
        )
    );;
  }
  parameter: period_size {
    label: "PoP Period Size"
    description: "The defaults should work intuitively (should align with the selected dimension, i.e. the grain of the rows), but you can use this if you need to specify a different offset amount.  For example, you might want to see daily results, but compare to 52 WEEKS prior"
    type: unquoted
    allowed_value: {value:"Day"}
    allowed_value: {value:"Month"}
    allowed_value: {value:"Year"} # allowed_value: {value:"Week"} # allowed_value: {value:"Quarter"} # other timeframes could be handled with some adjustments, but may not be universally supported for each dialect and may be superfluous to users.  For example, Weeks doesn't have a looker expression, so unlike those below, you would need to create a templated sql add_weeks formula (using your dialect), something like dimension: pop_sql_weeks_using_now  {type: date_raw expression:  dateadd(Weeks,${periods_ago},${now_sql});;}
    allowed_value: {value:"Default" label:"Default Based on Selection"}
    default_value: "Default"
  }

  dimension: now_sql {
    type: date_raw
    expression: now();;
  }
  dimension: now_converted_to_date_with_tz_sql {
    hidden: yes
    type: date
    expression: now();;
  }

  dimension: pop_sql_years_using_now  {type: date_raw expression:  add_years(${periods_ago},${now_sql});;}#use looker expressions to get dialect specific sql for date add functions
  dimension: pop_sql_months_using_now {type: date_raw expression:  add_months(${periods_ago},${now_sql});;}
  dimension: pop_sql_days_using_now   {type: date_raw expression:  add_days(${periods_ago},${now_sql});;}

}

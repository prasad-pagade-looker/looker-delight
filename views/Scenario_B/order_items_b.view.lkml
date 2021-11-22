include: "/views/order_items.view"
include: "/**/Scenario_B/*.view"

view: +order_items {

  parameter: select_timeframe{
    type: unquoted
    default_value: "YEAR"
    allowed_value: {
      label: "YEAR"
      value: "YEAR"
    }

    allowed_value: {
      label: "WEEK"
      value: "WEEK"
    }

    allowed_value: {
      label: "MONTH"
      value: "MONTH"
    }
  }

  dimension: reporting_period {
   # group_label: "Order Date"
    sql: CASE
        WHEN EXTRACT({% parameter select_timeframe %} from ${created_raw}) = EXTRACT({% parameter select_timeframe %} from CURRENT_TIMESTAMP())
        AND ${created_raw} < CURRENT_TIMESTAMP()
        THEN 'This {% parameter select_timeframe %} to Date'

        WHEN EXTRACT({% parameter select_timeframe %} from ${created_raw}) + 1 = EXTRACT({% parameter select_timeframe %} from CURRENT_TIMESTAMP())
        AND CAST(FORMAT_TIMESTAMP('%j', ${created_raw}) AS INT64) <= CAST(FORMAT_TIMESTAMP('%j', CURRENT_TIMESTAMP()) AS INT64)
        THEN 'Last {% parameter select_timeframe %} to Date'

      END
       ;;
  }

#   ######## Flexible PoP method #####################
#   #Refine YOUR date field by simply updating the dimension group name to match your base date field
#   dimension_group: created {
#     convert_tz: no #we need to inject the conversion before the date manipulation
#     datatype: date #our timezone conversion that we leverage results in a daily source datatype
#     sql:{% assign now_converted_to_date_with_timezone_sql = "${pop_support.now_converted_to_date_with_tz_sql::date}" %}{% assign now_unconverted_sql = pop_support.now_sql._sql %}{%comment%}pulling in logic from pop support template, within which we'll inject the original sql. Use $ {::date} when we want to get looker to do conversions, but _sql to extract raw sql {%endcomment%}
#           {% assign selected_period_size = selected_period_size._sql | strip %}
#           {%if selected_period_size == 'Day'%}{% assign pop_sql_using_now = "${pop_support.pop_sql_days_using_now}" %}{%elsif selected_period_size == 'Month'%}{% assign pop_sql_using_now = "${pop_support.pop_sql_months_using_now}" %}{%else%}{% assign pop_sql_using_now = "${pop_support.pop_sql_years_using_now}" %}{%endif%}
#           {% assign my_date_converted = now_converted_to_date_with_timezone_sql | replace:now_unconverted_sql,"${EXTENDED}" %}
#           {% if pop_support.periods_ago._in_query %}{{ pop_sql_using_now | replace: now_unconverted_sql, my_date_converted }}
#           {%else%}{{my_date_converted}}
#           {%endif%};;#wraps your original sql (i.e. ${EXTENDED}) inside custom pop logic, leveraging the parameterized selected-period-size-or-smart-default (defined below)
#   }

#   #Selected Period Size sets up Default Period Lengths to compare use for each of your timeframes, if the user doesn't adjust the PoP period size parameter
#   #If you only wanted YOY to be available, simply hard code this to year and hide the timeframes parameter in pop support
#   dimension: selected_period_size {
#     hidden: yes
#     sql:{%if pop_support.period_size._parameter_value != 'Default'%}{{pop_support.period_size._parameter_value}}
#         {% else %}
#           {% if
# created_date._is_selected %}Day
#           {% elsif
# created_month._is_selected %}Month
#           {% else %}Year
#           {% endif %}
#         {% endif %};;#!Update the liquid that mentions created_date and created_month to point to your timeframes, and potentiall add more checks for other timeframes
#   }

#   dimension: created_date_periods_ago_pivot {#!Update to match your base field name. This is generic sql logic but it is helpful to manifest the key pivot field in your dimension_group's group label.
#     label: "{% if _field._in_query%}Pop Period (Created {{selected_period_size._sql}}){%else%} Pivot for Period Over Period{%endif%}"#this complex label makes the 'PIVOT ME' instruction clear in the field picker, but uses a dynamically output lanbel based on the period size selected
#     group_label: "Created Date" #!Update this group label if necessary to make it fall in your date field's group_label
#     can_filter: no
#     order_by_field: pop_support.periods_ago #sort numerically/chronologically.
#     sql:{% assign period_label_sql = "${pop_support.period_label_sql}" %}{% assign selected_period_size = selected_period_size._sql | strip%}{% assign label_using_selected_period_size = period_label_sql | replace: 'REPLACE_WITH_PERIOD',selected_period_size%}{{label_using_selected_period_size}};;
#   }

# # Optional Validation Support field.  If there's ever any confusion with the results of PoP, it's helpful to see the exact min and max times of your raw data flowing through.
#   measure: pop_validation {
#     view_label: "PoP - VALIDATION - TO BE HIDDEN"
#     label: "Range of Raw Dates Included"
#     description: "Note: does not reflect timezone conversion"
#     sql:{%assign base_sql = '${TABLE}.created_at'%}concat(concat(min({{base_sql}}),' to '),max({{base_sql}}));;#!Paste the sql parameter value from the original date fields as the variable value for base_sql
#   }
}

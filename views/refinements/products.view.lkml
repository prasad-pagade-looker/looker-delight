include: "/views/products.view.lkml"
  view: +products {

    filter: brand_filter1 {

      suggest_dimension: brand

    }



dimension: brand_comparitor {

  type: string

  sql:

      CASE

        WHEN {% condition brand_select %} ${brand} {% endcondition %} AND ${num.n} = 1

          THEN ${brand}

        ELSE 'Total Of Population'

      END ;;

  }
  }

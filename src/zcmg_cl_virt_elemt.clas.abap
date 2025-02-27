CLASS zcmg_cl_virt_elemt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcmg_cl_virt_elemt IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    if iv_entity = 'ZCMG_C_TRAVEL'.

        LOOP AT it_requested_calc_elements into data(ls_calc_elements).

            if ls_calc_elements = 'DISCOUNTPRICE'.
              APPEND 'TOTALPRICE' TO et_requested_orig_elements.
            endif.

        ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA lt_original_data TYPE STANDARD TABLE OF zcmg_c_travel WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<ls_original_data>).
        <ls_original_data>-DiscountPrice = <ls_original_data>-TotalPrice - ( <ls_original_data>-TotalPrice * ( 1 / 10 ) ).
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.

ENDCLASS.

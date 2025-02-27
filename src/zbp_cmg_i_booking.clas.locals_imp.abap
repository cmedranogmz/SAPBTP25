CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Booking RESULT result.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zcmg_i_travel
    ENTITY Booking
    FIELDS ( BookingId BookingDate CustomerId BookingStatus )
    WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
    RESULT DATA(lt_booking_result).

    result = VALUE #( FOR ls_travel IN lt_booking_result (
                        %key                      = ls_travel-%key
                        %assoc-_BookingSupplement = if_abap_behv=>fc-o-enabled ) ).

  ENDMETHOD.

  METHOD calculateTotalFlightPrice.

    IF NOT keys IS INITIAL.
      zcmg_cl_aux_travel=>calculate_price( it_travel_id = VALUE #( FOR GROUPS <booking> OF booking_key IN keys
                                                                        GROUP BY booking_key-TravelId WITHOUT MEMBERS ( <booking> ) ) ).
    ENDIF.

  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY zcmg_i_travel\\Booking
        FIELDS ( BookingStatus )
        WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
        RESULT DATA(lt_booking_result).

    LOOP AT lt_booking_result INTO DATA(ls_booking_result).

      CASE ls_booking_result-BookingStatus.
        WHEN 'N'. "New

        WHEN 'X'. "Cancelled

        WHEN 'B'. " Booked

        WHEN OTHERS.

          DATA(lv_booking_msg) = ls_booking_result-BookingId.
          SHIFT lv_booking_msg LEFT DELETING LEADING '0'.

          APPEND VALUE #( %key = ls_booking_result-%key ) TO failed-booking.

          APPEND VALUE #( %key = ls_booking_result-%key
                          %msg = new_message( id       = 'ZCMG_MC_TRAVEL'
                                              number   = '007' " Status not valid for Booking &1
                                              v1       = lv_booking_msg " ls_booking_result-BookingId
                                              severity = if_abap_behv_message=>severity-error )
                          %element-bookingStatus = if_abap_behv=>mk-on ) TO reported-booking.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

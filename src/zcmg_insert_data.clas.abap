CLASS zcmg_insert_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCMG_INSERT_DATA IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    out->write( 'Data loading begins...' ).

    DATA: lt_travel   TYPE TABLE OF zcmg_travel,
          lt_booking  TYPE TABLE OF zcmg_booking,
          lt_book_sup TYPE TABLE OF zcmg_booksuppl.

    SELECT  travel_id,
            agency_id,
            customer_id,
            begin_date,
            end_date,
              booking_fee,
              total_price,
              currency_code,
              description,
              status AS overall_status,
              createdby AS created_by,
              createdat AS created_at,
              lastchangedby AS last_changed_by,
              lastchangedat AS last_changed_at
    FROM /dmo/travel INTO CORRESPONDING FIELDS OF TABLE @lt_travel
    UP TO 50 ROWS.

    SELECT * FROM /dmo/booking
    FOR ALL ENTRIES IN @lt_travel
    WHERE travel_id EQ @lt_travel-travel_id
    INTO CORRESPONDING FIELDS OF TABLE @lt_booking.

    SELECT * FROM /dmo/book_suppl
    FOR ALL ENTRIES IN @lt_booking
    WHERE travel_id EQ @lt_booking-travel_id
    AND  booking_id EQ @lt_booking-booking_id
    INTO CORRESPONDING FIELDS OF TABLE @lt_book_sup.

    DELETE FROM: zcmg_travel,
                zcmg_booking,
                zcmg_booksuppl.

    INSERT : zcmg_travel FROM TABLE @lt_travel,
             zcmg_booking FROM TABLE @lt_booking,
             zcmg_booksuppl FROM TABLE @lt_book_sup.

    IF sy-subrc EQ 0.
      out->write( 'Data loaded into database!' ).
    ENDIF.


  ENDMETHOD.
ENDCLASS.

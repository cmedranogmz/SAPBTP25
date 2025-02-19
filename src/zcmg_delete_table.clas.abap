CLASS zcmg_delete_table DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCMG_DELETE_TABLE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DELETE FROM zcmg_rent_brands.

    IF  sy-subrc EQ 0.
      out->write( 'All data deleted' ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.

CLASS zcmg_cl_ex_update_entity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcmg_cl_ex_update_entity IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF zcmg_i_travel
        ENTITY Travel
        UPDATE FIELDS ( AgencyId Description )
        WITH VALUE #( ( TravelId = '00000012' " 00000012
                        AgencyId = '070025'   " 070028
                        Description = 'New external update' ) ) " Sightseeing in Miami, Florida
        FAILED DATA(failed)
        REPORTED DATA(reported).

    READ ENTITIES OF zcmg_i_travel
        ENTITY Travel
        FIELDS ( AgencyId Description )
        WITH VALUE #( ( TravelId = '00000012' ) )
        RESULT DATA(lt_travel_data)
        FAILED failed
        REPORTED reported.

    COMMIT ENTITIES.

    IF failed IS INITIAL.
      out->write( 'Commit Successfull' ).
    ELSE.
      out->write( 'Commit Failed' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

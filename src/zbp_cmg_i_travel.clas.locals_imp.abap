CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS: acceptTravel FOR MODIFY IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result,
      rejectTravel FOR MODIFY IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result,
      createTravelByTemplate FOR MODIFY IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS: validateCustomer FOR VALIDATE ON SAVE IMPORTING keys FOR Travel~validateCustomer,
      validateDates FOR VALIDATE ON SAVE IMPORTING keys FOR Travel~validateDates,
      validateStatus FOR VALIDATE ON SAVE IMPORTING keys FOR Travel~validateStatus.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zcmg_i_travel
    ENTITY Travel
    FIELDS ( TravelId OverallStatus )
    WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
    RESULT DATA(lt_travel_result).

    result = VALUE #( FOR ls_travel IN lt_travel_result (
                        %key                 = ls_travel-%key
                        %field-TravelId      = if_abap_behv=>fc-f-read_only
                        %field-OverallStatus = if_abap_behv=>fc-f-read_only
                        %assoc-_Booking      = if_abap_behv=>fc-o-enabled
                        %action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = 'A' " A = Accept status
                                                       THEN if_abap_behv=>fc-o-disabled
                                                       ELSE if_abap_behv=>fc-o-enabled )
                        %action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = 'X' " X = Rejected Status
                                                       THEN if_abap_behv=>fc-o-disabled
                                                       ELSE if_abap_behv=>fc-o-enabled  ) ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name(  ) EQ 'CB9980011994' " CB9980011994 = SAP User CMG
                            THEN if_abap_behv=>auth-allowed
                            ELSE if_abap_behv=>auth-unauthorized ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).

      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).

      <ls_result> = VALUE #( %key                           = <ls_result>-%key
                             %op-%update                    = lv_auth
                             %delete                        = lv_auth
                             %action-acceptTravel           = lv_auth
                             %action-rejectTravel           = lv_auth
                             %action-createTravelByTemplate = lv_auth
                             %assoc-_Booking                = lv_auth ).

    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES OF zcmg_i_travel IN LOCAL MODE
      ENTITY Travel
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR key_row IN keys ( TravelId      = key_row-TravelId
                                          OverallStatus = 'A' ) ) " A = Accepted status
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zcmg_i_travel
    ENTITY Travel
    FIELDS ( AgencyId
             CustomerId
             BeginDate
             EndDate
             BookingFee
             TotalPrice
             CurrencyCode
             OverallStatus
             Description
             CreatedBy
             CreatedAt
             LastChangedBy
             LastChangedAt )
    WITH VALUE #( FOR key_row_read IN keys ( TravelId = key_row_read-TravelId ) )
    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel ( TravelId = ls_travel-TravelId
                                                   %param   = ls_travel ) ).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_travel_msg) = <ls_travel>-TravelId.
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.

      APPEND VALUE #( TravelId = <ls_travel>-TravelId
                      %msg     = new_message( id       = 'ZCMG_MC_TRAVEL'
                                              number   = '005'
                                              v1       = lv_travel_msg
                                              severity = if_abap_behv_message=>severity-success )
                      %element-customerID = if_abap_behv=>mk-on ) TO reported-travel.

    ENDLOOP.


  ENDMETHOD.

  METHOD createTravelByTemplate.

*    keys[ 1 ]-%key "Leer clave para la entidad
*    result[ 1 ]-   "Objeto que retorna la salida del metodo
*    mapped         "Estrucutra para mapear los valores a las entidades
*    failed         "Estrucutra para mapear fallos
*    reported       "Estrucutra para reportar fallos atraves de mensajes en capa del consumidor

* Lectura de datos de la entidad Travel - Opcion 1 (Recomendada)
    READ ENTITIES OF zcmg_i_travel
    ENTITY Travel
    FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
    WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
    RESULT DATA(lt_entity_travel)
    FAILED failed
    REPORTED reported.

* Lectura de datos de la entidad Travel - Opcion 2
*    READ ENTITY zcmg_i_travel
*    FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
*    WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
*    RESULT DATA(lt_entity_travel)
*    FAILED failed
*    REPORTED reported.

    DATA lt_create_travel TYPE TABLE FOR CREATE zcmg_i_travel\\Travel.

    DATA(lv_today) = cl_abap_context_info=>get_system_date(  ).

    SELECT MAX( travel_id ) FROM zcmg_travel
    INTO @DATA(lv_travel_id).

    lt_create_travel = VALUE #( FOR create_row IN lt_entity_travel INDEX INTO idx
                                    ( TravelId      = lv_travel_id + idx
                                      AgencyId      = create_row-AgencyId
                                      CustomerId    = create_row-CustomerId
                                      BeginDate     = lv_today
                                      EndDate       = lv_today + 30
                                      BookingFee    = create_row-BookingFee
                                      TotalPrice    = create_row-TotalPrice
                                      CurrencyCode  = create_row-CurrencyCode
                                      Description   = 'Add coments...'
                                      OverallStatus = 'O' ) ). "O - Open status

    MODIFY ENTITIES OF zcmg_i_travel
    IN LOCAL MODE ENTITY Travel
    CREATE FIELDS ( TravelID
                    AgencyId
                    CustomerId
                    BeginDate
                    EndDate
                    BookingFee
                    TotalPrice
                    CurrencyCode
                    Description
                    OverallStatus )
   WITH lt_create_travel
   MAPPED mapped
   FAILED failed
   REPORTED reported.

    result = VALUE #( FOR result_row IN lt_create_travel INDEX INTO idx
                         ( %cid_ref = keys[ idx ]-%cid_ref
                           %key     = keys[ idx ]-%key
                           %param   = CORRESPONDING #( result_row ) ) ).

  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF zcmg_i_travel IN LOCAL MODE
      ENTITY Travel
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR key_row IN keys ( TravelId      = key_row-TravelId
                                          OverallStatus = 'X' ) ) " X = Rejected status
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF zcmg_i_travel
    ENTITY Travel
    FIELDS ( AgencyId
             CustomerId
             BeginDate
             EndDate
             BookingFee
             TotalPrice
             CurrencyCode
             OverallStatus
             Description
             CreatedBy
             CreatedAt
             LastChangedBy
             LastChangedAt )
    WITH VALUE #( FOR key_row_read IN keys ( TravelId = key_row_read-TravelId ) )
    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel ( TravelId = ls_travel-TravelId
                                                   %param   = ls_travel ) ).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_travel_msg) = <ls_travel>-TravelId.
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.

      APPEND VALUE #( TravelId = <ls_travel>-TravelId
                      %msg     = new_message( id       = 'ZCMG_MC_TRAVEL'
                                              number   = '006'
                                              v1       = lv_travel_msg
                                              severity = if_abap_behv_message=>severity-success )
                      %element-customerID = if_abap_behv=>mk-on ) TO reported-travel.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF zcmg_i_travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).

    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer FIELDS customer_id
        FOR ALL ENTRIES IN @lt_customer
        WHERE customer_id EQ @lt_customer-customer_id
        INTO TABLE @DATA(lt_customer_db).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-CustomerId IS INITIAL
          OR NOT line_exists( lt_customer_db[ customer_id = <ls_travel>-CustomerId ] ).

        APPEND VALUE #( TravelId = <ls_travel>-TravelId ) TO failed-travel.

        APPEND VALUE #( TravelId = <ls_travel>-TravelId
                        %msg     = new_message( id       = 'ZCMG_MC_TRAVEL' " Clase de mensajes
                                                number   = '001'    " Customer &1 unknown
                                                v1       = <ls_travel>-TravelId
                                                severity = if_abap_behv_message=>severity-error )
                        %element-customerID = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD validateDates.

    READ ENTITY zcmg_i_travel\\Travel
        FIELDS ( BeginDate EndDate )
        WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
        RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      IF ls_travel_result-EndDate LT ls_travel_result-BeginDate.

        APPEND VALUE #( %key     = ls_travel_result-%key
                        TravelId = ls_travel_result-TravelId ) TO failed-travel.

        APPEND VALUE #( %key     = ls_travel_result-%key
                        %msg     = new_message( id       = 'ZCMG_MC_TRAVEL'
                                                number   = '003'
                                                v1       = ls_travel_result-BeginDate
                                                v2       = ls_travel_result-EndDate
                                                v3       = ls_travel_result-TravelId
                                                severity = if_abap_behv_message=>severity-error )
                        %element-beginDate = if_abap_behv=>mk-on
                        %element-endDate   = if_abap_behv=>mk-on ) TO reported-travel.

      ELSEIF ls_travel_result-BeginDate < cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #( %key     = ls_travel_result-%key
                        TravelId = ls_travel_result-TravelId ) TO failed-travel.

        APPEND VALUE #( %key     = ls_travel_result-%key
                        %msg     = new_message( id       = 'ZCMG_MC_TRAVEL'
                                                number   = '002' " Begin date &1 must be on after system date
                                                v1       = ls_travel_result-BeginDate
                                                severity = if_abap_behv_message=>severity-error )
                        %element-beginDate = if_abap_behv=>mk-on
                        %element-endDate   = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY zcmg_i_travel\\Travel
        FIELDS ( OverallStatus )
        WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
        RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      CASE ls_travel_result-OverallStatus.
        WHEN 'O'. "Open

        WHEN 'X'. "Cancelled

        WHEN 'A'. " Accepted

        WHEN OTHERS.

          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.

          APPEND VALUE #( %key = ls_travel_result-%key
                          %msg = new_message( id       = 'ZCMG_MC_TRAVEL'
                                              number   = '005' " Travel status not valid for travel &1
                                              v1       = ls_travel_result-OverallStatus
                                              severity = if_abap_behv_message=>severity-error )
                          %element-overallStatus = if_abap_behv=>mk-on ) TO reported-travel.

      ENDCASE.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZCMG_I_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.

    CONSTANTS: create TYPE string VALUE 'CREATE',
               update TYPE string VALUE 'UPDATE',
               delete TYPE string VALUE 'DELETE'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZCMG_I_TRAVEL IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_travel_log   TYPE STANDARD TABLE OF zcmg_log,
          lt_travel_log_u TYPE STANDARD TABLE OF zcmg_log.

    DATA(lv_user)  = cl_abap_context_info=>get_user_technical_name(  ).

    IF NOT create-travel IS INITIAL.

      lt_travel_log = CORRESPONDING #( create-travel MAPPING travel_id = TravelId ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log>).

        GET TIME STAMP FIELD <ls_travel_log>-created_at.
        <ls_travel_log>-changing_operation = lsc_zcmg_i_travel=>create.

        READ TABLE create-travel WITH KEY entity COMPONENTS TravelId = <ls_travel_log>-travel_id
            INTO DATA(ls_travel).

        IF sy-subrc EQ 0.

          IF ls_travel-%control-BookingFee EQ cl_abap_behv=>flag_changed.
            <ls_travel_log>-changed_field_name = 'booking_fee'.
            <ls_travel_log>-changed_value      = ls_travel-BookingFee.
            <ls_travel_log>-user_mod           = lv_user.
            TRY.
                <ls_travel_log>-change_id          = cl_system_uuid=>create_uuid_x16_static(  ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.

            APPEND <ls_travel_log> TO lt_travel_log_u.

          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDIF.

    IF NOT update-travel IS INITIAL.

      lt_travel_log = CORRESPONDING #( update-travel MAPPING travel_id = TravelId ).

      LOOP AT update-travel INTO DATA(ls_update_travel).

        ASSIGN lt_travel_log[ travel_id = ls_update_travel-TravelId ] TO FIELD-SYMBOL(<ls_travel_log_db>).

        GET TIME STAMP FIELD <ls_travel_log_db>-created_at.
        <ls_travel_log_db>-changing_operation = lsc_zcmg_i_travel=>update.


        IF ls_update_travel-%control-CustomerId EQ cl_abap_behv=>flag_changed.

          <ls_travel_log_db>-changed_field_name = 'customer_id'.
          <ls_travel_log_db>-changed_value = ls_update_travel-CustomerId.
          <ls_travel_log_db>-user_mod           = lv_user.
          TRY.
              <ls_travel_log_db>-change_id          = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.

          APPEND <ls_travel_log_db> TO lt_travel_log_u.

        ENDIF.

      ENDLOOP.

    ENDIF.

    IF NOT delete-travel IS INITIAL.

      lt_travel_log = CORRESPONDING #( delete-travel MAPPING travel_id = TravelId ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log_del>).
        GET TIME STAMP FIELD <ls_travel_log_del>-created_at.
        <ls_travel_log_del>-changing_operation = lsc_zcmg_i_travel=>delete.
        <ls_travel_log_del>-user_mod           = lv_user.
        TRY.
            <ls_travel_log_del>-change_id          = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.

        APPEND <ls_travel_log_del> to lt_travel_log_u.

      ENDLOOP.

    ENDIF.

    IF NOT lt_travel_log_u IS INITIAL.
      INSERT zcmg_log FROM TABLE @lt_travel_log_u.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

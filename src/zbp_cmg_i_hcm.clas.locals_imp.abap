CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CONSTANTS: created TYPE c LENGTH 1 VALUE 'C',
               updated TYPE c LENGTH 1 VALUE 'U',
               deleted TYPE c LENGTH 1 VALUE 'D'.

    TYPES: BEGIN OF  ty_buffer_master.
             INCLUDE TYPE zcmg_hcm AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer_master.

    TYPES: tt_master TYPE SORTED TABLE OF ty_buffer_master WITH UNIQUE KEY e_number.

    CLASS-DATA mt_buffer_master TYPE tt_master.

ENDCLASS.

CLASS lhc_HCMMaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR HCMMaster RESULT result.

    METHODS: create FOR MODIFY IMPORTING entities FOR CREATE HCMMaster,
      update FOR MODIFY IMPORTING entities FOR UPDATE HCMMaster,
      delete FOR MODIFY IMPORTING keys FOR DELETE HCMMaster,
      read FOR READ IMPORTING keys FOR READ HCMMaster RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK HCMMaster.

ENDCLASS.

CLASS lhc_HCMMaster IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    GET TIME STAMP FIELD DATA(lv_time_stamp).
    DATA(lv_uname) = cl_abap_context_info=>get_user_technical_name(  ).

    SELECT MAX( e_number ) FROM zcmg_hcm
     INTO @DATA(lv_max_employee_number).

    LOOP AT entities INTO DATA(ls_entities).

      ls_entities-%data-CreateDateTime = lv_time_stamp.
      ls_entities-%data-CreateUname = lv_uname.
      ls_entities-%data-ENumber = lv_max_employee_number + 1.

      INSERT VALUE #( flag = lcl_buffer=>created
                       data = CORRESPONDING #( ls_entities-%data MAPPING
                                            e_number        = ENumber
                                            e_name          = EName
                                            e_departament   = EDepartament
                                            status          = Status
                                            job_title       = JobTitle
                                            start_date      = StartDate
                                            end_date        = EndDate
                                            email           = Email
                                            m_number        = MNumber
                                            m_name          = MName
                                            m_departament   = MDepartament
                                            create_date_time = CreateDateTime
                                            create_uname     = CreateUname
                                            last_change_date = LastChangeDate
                                            last_change_by   = LastChangeBy ) )
                                       INTO TABLE lcl_buffer=>mt_buffer_master.

      IF NOT ls_entities-%cid IS INITIAL.
        INSERT VALUE #( %cid = ls_entities-%cid
                        enumber = ls_entities-ENumber ) INTO TABLE mapped-hcmmaster.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.

    GET TIME STAMP FIELD DATA(lv_time_stamp).
    DATA(lv_uname) = cl_abap_context_info=>get_user_technical_name(  ).

    LOOP AT entities INTO DATA(ls_entities).

      SELECT SINGLE * FROM zcmg_hcm
        WHERE e_number EQ @ls_entities-%data-ENumber
        INTO @DATA(ls_ddbb).

      ls_entities-%data-LastChangeDate = lv_time_stamp.
      ls_entities-%data-LastChangeBy = lv_uname.

      INSERT VALUE #( flag = lcl_buffer=>updated
                       data = VALUE #( e_number = ls_entities-ENumber

                                       e_name = COND #( WHEN ls_entities-%control-EName EQ if_abap_behv=>mk-on
                                                        THEN ls_entities-%data-EName
                                                        ELSE ls_ddbb-e_name )
                                       e_departament = COND #( WHEN ls_entities-%control-EDepartament EQ if_abap_behv=>mk-on
                                                        THEN ls_entities-%data-EDepartament
                                                        ELSE ls_ddbb-e_departament )

                                       status = COND #( WHEN ls_entities-%control-Status EQ if_abap_behv=>mk-on
                                                        THEN ls_entities-%data-Status
                                                        ELSE ls_ddbb-status )

                                            job_title   = COND #( WHEN ls_entities-%control-JobTitle EQ if_abap_behv=>mk-on
                                                        THEN ls_entities-%data-JobTitle
                                                        ELSE ls_ddbb-job_title )

                                            start_date      = COND #( WHEN ls_entities-%control-StartDate EQ if_abap_behv=>mk-on
                                                        THEN ls_entities-%data-StartDate
                                                        ELSE ls_ddbb-start_date )

                                            end_date        = COND #( WHEN ls_entities-%control-EndDate EQ if_abap_behv=>mk-on
                                                        THEN ls_entities-%data-EndDate
                                                        ELSE ls_ddbb-end_date )

                                            email       = COND #( WHEN ls_entities-%control-Email EQ if_abap_behv=>mk-on
                                                        THEN ls_entities-%data-Email
                                                        ELSE ls_ddbb-email )

                                            m_number      = COND #( WHEN ls_entities-%control-MNumber EQ if_abap_behv=>mk-on
                                                        THEN ls_entities-%data-MNumber
                                                        ELSE ls_ddbb-e_number )

                                            m_name        = COND #( WHEN ls_entities-%control-MName EQ if_abap_behv=>mk-on
                                                        THEN ls_entities-%data-MName
                                                        ELSE ls_ddbb-m_name )

                                            m_departament   = COND #( WHEN ls_entities-%control-MDepartament EQ if_abap_behv=>mk-on
                                                        THEN ls_entities-%data-MDepartament
                                                        ELSE ls_ddbb-m_departament )

                                            create_date_time = ls_ddbb-create_date_time
                                            create_uname     = ls_ddbb-create_uname
                                            last_change_date = ls_entities-%data-LastChangeDate
                                            last_change_by   = ls_entities-%data-LastChangeBy  ) )
                                       INTO TABLE lcl_buffer=>mt_buffer_master.

      IF NOT ls_entities-ENumber IS INITIAL.
        INSERT VALUE #( %cid = ls_entities-%data-ENumber
                        enumber = ls_entities-%data-ENumber ) INTO TABLE mapped-hcmmaster.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    LOOP AT keys INTO DATA(ls_keys).

      INSERT VALUE #( flag = lcl_buffer=>deleted
                      data = VALUE #( e_number = ls_keys-%key-ENumber ) ) INTO TABLE lcl_buffer=>mt_buffer_master.

      IF NOT ls_keys IS INITIAL.
        INSERT VALUE #( %cid = ls_keys-%key-ENumber
                        Enumber = ls_keys-%key-ENumber ) INTO TABLE mapped-hcmmaster.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_HCMMaster DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_HCMMaster IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    DATA: lt_data_created TYPE STANDARD TABLE OF zcmg_hcm,
          lt_data_updated TYPE STANDARD TABLE OF zcmg_hcm,
          lt_data_deleted TYPE STANDARD TABLE OF zcmg_hcm.

    lt_data_created =  VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                                  WHERE ( flag = lcl_buffer=>created ) ( <row>-data ) ).

    IF NOT lt_data_created IS INITIAL.
      INSERT zcmg_hcm FROM TABLE @lt_data_created.
    ENDIF.

    lt_data_updated =  VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                                  WHERE ( flag = lcl_buffer=>updated ) ( <row>-data ) ).

    IF NOT lt_data_updated IS INITIAL.
      UPDATE zcmg_hcm FROM TABLE @lt_data_updated.
    ENDIF.

    lt_data_deleted =  VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                                  WHERE ( flag = lcl_buffer=>deleted ) ( <row>-data ) ).

    IF NOT lt_data_deleted IS INITIAL.
      DELETE zcmg_hcm FROM TABLE @lt_data_deleted.
    ENDIF.

    CLEAR lcl_buffer=>mt_buffer_master.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

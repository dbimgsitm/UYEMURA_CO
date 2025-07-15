CLASS lhc_mtlcmaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR mtlcmaster RESULT result.

    METHODS beforesave FOR VALIDATE ON SAVE
      IMPORTING keys FOR mtlcmaster~beforesave.

ENDCLASS.

CLASS lhc_mtlcmaster IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD beforesave.

    READ ENTITIES OF zi_mtledgercategory_master IN LOCAL MODE
    ENTITY mtlcmaster
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_mtlcmaster)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

*   자재원장타입 중복값 체크
    SELECT materialledgercategory
    FROM ztgsco0030
    WHERE materialledgercategory IN ( SELECT materialledgercategory
                                    FROM @lt_mtlcmaster AS lt_checkdata )
      AND delete_flag = ''
     INTO TABLE @DATA(lt_check).


    IF sy-subrc = 0.
      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                        %fail-cause = if_abap_behv=>cause-conflict
                        id = ls_key-id
                      )  TO failed-mtlcmaster.
      ENDLOOP.

      LOOP AT lt_check INTO DATA(ls_check).
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                        %msg = new_message(
                            id = 'ZMCGSCO0010'
                            number = '003'
                            v1 = ls_check-materialledgercategory
                            severity = if_abap_behv_message=>severity-error )
                      ) TO reported-mtlcmaster.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_mtledgercategory_master DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_mtledgercategory_master IMPLEMENTATION.

  METHOD save_modified.
    DATA : ls_ztgsco0030  TYPE ztgsco0030,
           ls_ztgsco0030h TYPE ztgsco0030h.

**********************************************************************
* Create
**********************************************************************
    IF create-mtlcmaster IS NOT INITIAL.
      LOOP AT create-mtlcmaster REFERENCE INTO DATA(lr_c_mtlcmaster).
        ls_ztgsco0030 = VALUE #(  id = lr_c_mtlcmaster->id
                                  movementtype = lr_c_mtlcmaster->movementtype
                                  movementtypename = lr_c_mtlcmaster->movementtypename
                                  materialledgercategory = lr_c_mtlcmaster->materialledgercategorytext
                                  check_detailed = lr_c_mtlcmaster->CheckDetailed
                                  delete_flag = lr_c_mtlcmaster->deleteflag
                                  created_by = lr_c_mtlcmaster->createdby
                                  created_at = lr_c_mtlcmaster->createdat
                                  last_changed_by = lr_c_mtlcmaster->lastchangedby
                                  last_changed_at = lr_c_mtlcmaster->lastchangedat
                                ).
        INSERT INTO ztgsco0030 VALUES @ls_ztgsco0030.

        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0030h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_c_mtlcmaster->id
                                          action = 'C'
                                          movementtype = lr_c_mtlcmaster->movementtype
                                          movementtypename = lr_c_mtlcmaster->movementtypename
                                          materialledgercategory = lr_c_mtlcmaster->materialledgercategorytext
                                          check_detailed = lr_c_mtlcmaster->CheckDetailed
                                          delete_flag = lr_c_mtlcmaster->deleteflag
                                          created_by = lr_c_mtlcmaster->createdby
                                          created_at = lr_c_mtlcmaster->createdat
                                          last_changed_by = lr_c_mtlcmaster->lastchangedby
                                          last_changed_at = lr_c_mtlcmaster->lastchangedat
                                        ).
              INSERT INTO ztgsco0030h VALUES @ls_ztgsco0030h.

            CATCH cx_uuid_error INTO DATA(exc_c).
              DATA(excc) = exc_c.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Delete
**********************************************************************
    IF delete-mtlcmaster IS NOT INITIAL.
      SELECT *
        FROM ztgsco0030
        WHERE id IN ( SELECT id FROM @delete-mtlcmaster AS zmtlcmaster )
        INTO TABLE @DATA(lr_r_mtlcmaster).

      LOOP AT delete-mtlcmaster REFERENCE INTO DATA(lr_d_mtlcmaster).
        UPDATE ztgsco0030 SET delete_flag = 'X' WHERE id = @lr_d_mtlcmaster->id.
        READ TABLE lr_r_mtlcmaster WITH KEY id = lr_d_mtlcmaster->id INTO DATA(lr_r_data).
        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""

          TRY.
              ls_ztgsco0030h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_r_data-id
                                          action = 'D'
                                          movementtype = lr_r_data-movementtype
                                          movementtypename = lr_r_data-movementtypename
                                          materialledgercategory = lr_r_data-materialledgercategorytext
                                          check_detailed = lr_r_data-check_detailed
                                          delete_flag = lr_r_data-delete_flag
                                          created_by = lr_r_data-created_by
                                          created_at = lr_r_data-created_at
                                          last_changed_by = lr_r_data-last_changed_by
                                          last_changed_at = lr_r_data-last_changed_at
                                        ).
              INSERT INTO ztgsco0030h VALUES @ls_ztgsco0030h.
            CATCH cx_uuid_error INTO DATA(exc_d).
              DATA(excd) = exc_d.
          ENDTRY.

        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Update
**********************************************************************
    IF update-mtlcmaster IS NOT INITIAL.

      DATA : updateflag TYPE abap_boolean.
      CLEAR updateflag.

      LOOP AT update-mtlcmaster REFERENCE INTO DATA(lr_u_mtlcmaster).
        "자재원장타입명
        IF lr_u_mtlcmaster->%control-materialledgercategorytext = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0030 SET materialledgercategorytext = @lr_u_mtlcmaster->materialledgercategorytext WHERE id = @lr_u_mtlcmaster->id.
        ENDIF.

        "입출고상세화 여부
        IF lr_u_mtlcmaster->%control-CheckDetailed = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0030 SET check_detailed = @lr_u_mtlcmaster->CheckDetailed WHERE id = @lr_u_mtlcmaster->id.
        ENDIF.

        IF sy-subrc = 0 AND updateflag = 'X'.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0030h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_u_mtlcmaster->id
                                          action = 'U'
                                          movementtype = lr_u_mtlcmaster->movementtype
                                          movementtypename = lr_u_mtlcmaster->movementtypename
                                          materialledgercategory = lr_u_mtlcmaster->materialledgercategorytext
                                          check_detailed = lr_u_mtlcmaster->CheckDetailed
                                          delete_flag = lr_u_mtlcmaster->deleteflag
                                          created_by = lr_u_mtlcmaster->createdby
                                          created_at = lr_u_mtlcmaster->createdat
                                          last_changed_by = lr_u_mtlcmaster->lastchangedby
                                          last_changed_at = lr_u_mtlcmaster->lastchangedat
                                        ).
              INSERT INTO ztgsco0030h VALUES @ls_ztgsco0030h.

            CATCH cx_uuid_error INTO DATA(exc_u).
              DATA(excu) = exc_u.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

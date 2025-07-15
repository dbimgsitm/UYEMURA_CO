CLASS lhc_mtmaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR mtmaster RESULT result.

    METHODS beforesave FOR VALIDATE ON SAVE
      IMPORTING keys FOR mtmaster~beforesave.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_authorizations FOR mtmaster RESULT result.

ENDCLASS.

CLASS lhc_mtmaster IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.

*   결과 행
    DATA result_line LIKE LINE OF result.
*   활성 인스턴스를 조회할 키 테이블 (활성 인스턴스 : 저장된 데이터)
    DATA keys_of_active_instances TYPE TABLE FOR INSTANCE FEATURES KEY zi_movementtype_master.

*   입력 파라미터
    LOOP AT keys INTO DATA(key).

      CLEAR keys_of_active_instances.
      APPEND INITIAL LINE TO  keys_of_active_instances.

*     %tky(technical key) 복사
      keys_of_active_instances[ 1 ]-%tky = key-%tky.

*     드래프트가 아닌 (저장된 값)으로 설정
      keys_of_active_instances[ 1 ]-%is_draft = if_abap_behv=>mk-off.

      result_line-%tky = key-%tky.

*     저장된 값을 조회
      READ ENTITIES OF zi_movementtype_master IN LOCAL MODE
            ENTITY mtmaster
*              ALL FIELDS
              FIELDS ( movementtype )
              WITH CORRESPONDING #( keys_of_active_instances )
            RESULT DATA(active_entity).

*     활성 인스턴스가 존재하면 readonly로 바꿈
      IF active_entity IS NOT INITIAL.
        result_line-%features-%field-movementtype =  if_abap_behv=>fc-f-read_only .
      ELSE.
        result_line-%features-%field-movementtype = if_abap_behv=>fc-f-unrestricted.
      ENDIF.

      APPEND result_line TO result.

    ENDLOOP.
  ENDMETHOD.

  METHOD beforesave.

*   메세지 처음에 전부 정리
    APPEND VALUE #(
                      %create = if_abap_behv=>mk-on
                      %element-movementtype = if_abap_behv=>mk-on
                      %is_draft = if_abap_behv=>mk-on
                      id = keys[ 1 ]-id
                      %state_area = if_abap_behv=>state_area_all
                    ) TO reported-mtmaster.

    DATA : lv_error TYPE abap_boolean.

    READ ENTITIES OF zi_movementtype_master IN LOCAL MODE
    ENTITY mtmaster
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_mtmaster)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

*   유효성 체크
    SELECT movementtype
      FROM @lt_mtmaster AS lt_chek
    INTO TABLE @DATA(lt_checktype).

    DATA: lr_matcher TYPE REF TO cl_abap_matcher,
          lv_success.


    DATA(lv_pattern) = '[0-9]+'.

    LOOP AT lt_checktype INTO DATA(ls_checktype).

      lr_matcher = cl_abap_matcher=>create_pcre(
                       pattern = lv_pattern
                       text    = ls_checktype-movementtype
                    ).
      lv_success = lr_matcher->match( ).

      IF  lv_success NE 'X'.
        lv_error = abap_true.
        APPEND VALUE #( %is_draft = if_abap_behv=>mk-on
                        %create = if_abap_behv=>mk-on
                        id = keys[ 1 ]-id
                        %element-movementtype = if_abap_behv=>mk-on
                        %state_area = '01'
                        %msg = new_message(
                            id = 'ZMCGSCO0010'
                            number = '005'
                            severity = if_abap_behv_message=>severity-error
                      ) ) TO reported-mtmaster.

      ENDIF.
    ENDLOOP.

*   입출고타입 중복값 체크
    SELECT movementtype
    FROM ztgsco0020
    WHERE movementtype IN ( SELECT movementtype
                              FROM @lt_mtmaster AS lv_checkdata )
      AND delete_flag = ''
     INTO TABLE @DATA(lt_check).

    IF sy-subrc = 0.
      lv_error = abap_true.
      LOOP AT lt_check INTO DATA(ls_check).
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                        %element-movementtype = if_abap_behv=>mk-on
                        %is_draft = if_abap_behv=>mk-on
                        id = keys[ 1 ]-id
                        %state_area = '01'
                        %msg = new_message(
                            id = 'ZMCGSCO0010'
                            number = '002'
                            v1 = ls_check-movementtype
                            severity = if_abap_behv_message=>severity-error )
                      ) TO reported-mtmaster.
      ENDLOOP.
    ENDIF.

    "오류 발생
    IF lv_error = abap_true.
      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #(  %create = if_abap_behv=>mk-on
                    %fail-cause = if_abap_behv=>cause-conflict
                    id = ls_key-id
                    )  TO failed-mtmaster.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_movementtype_master DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_movementtype_master IMPLEMENTATION.

  METHOD save_modified.
    DATA : ls_ztgsco0020  TYPE ztgsco0020,
           ls_ztgsco0020h TYPE ztgsco0020h.

**********************************************************************
* Create
**********************************************************************
    IF create-mtmaster IS NOT INITIAL.
      LOOP AT create-mtmaster REFERENCE INTO DATA(lr_c_mtmaster).
        ls_ztgsco0020 = VALUE #(  id = lr_c_mtmaster->id
                                  movementtype = lr_c_mtmaster->movementtype
                                  movementtypename = lr_c_mtmaster->movementtypename
                                  delete_flag = lr_c_mtmaster->deleteflag
                                  created_by = lr_c_mtmaster->createdby
                                  created_at = lr_c_mtmaster->createdat
                                  last_changed_by = lr_c_mtmaster->lastchangedby
                                  last_changed_at = lr_c_mtmaster->lastchangedat
                                ).
        INSERT INTO ztgsco0020 VALUES @ls_ztgsco0020.

        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0020h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_c_mtmaster->id
                                          action = 'C'
                                          movementtype = lr_c_mtmaster->movementtype
                                          movementtypename = lr_c_mtmaster->movementtypename
                                          delete_flag = lr_c_mtmaster->deleteflag
                                          created_by = lr_c_mtmaster->createdby
                                          created_at = lr_c_mtmaster->createdat
                                          last_changed_by = lr_c_mtmaster->lastchangedby
                                          last_changed_at = lr_c_mtmaster->lastchangedat
                                        ).
              INSERT INTO ztgsco0020h VALUES @ls_ztgsco0020h.

            CATCH cx_uuid_error INTO DATA(exc_c).
              DATA(excc) = exc_c.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Delete
**********************************************************************
    IF delete-mtmaster IS NOT INITIAL.
      SELECT *
        FROM ztgsco0020
        WHERE id IN ( SELECT id FROM @delete-mtmaster AS zmtmaster )
        INTO TABLE @DATA(lr_r_mtmaster).

      LOOP AT delete-mtmaster REFERENCE INTO DATA(lr_d_mtmaster).
        UPDATE ztgsco0020 SET delete_flag = 'X' WHERE id = @lr_d_mtmaster->id.
        READ TABLE lr_r_mtmaster WITH KEY id = lr_d_mtmaster->id INTO DATA(lr_r_data).
        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""

          TRY.
              ls_ztgsco0020h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_r_data-id
                                          action = 'D'
                                          movementtype = lr_r_data-movementtype
                                          movementtypename = lr_r_data-movementtypename
                                          delete_flag = lr_r_data-delete_flag
                                          created_by = lr_r_data-created_by
                                          created_at = lr_r_data-created_at
                                          last_changed_by = lr_r_data-last_changed_by
                                          last_changed_at = lr_r_data-last_changed_at
                                        ).
              INSERT INTO ztgsco0020h VALUES @ls_ztgsco0020h.
            CATCH cx_uuid_error INTO DATA(exc_d).
              DATA(excd) = exc_d.
          ENDTRY.

        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Update
**********************************************************************
    IF update-mtmaster IS NOT INITIAL.

      DATA : updateflag TYPE abap_boolean.
      CLEAR updateflag.

      LOOP AT update-mtmaster REFERENCE INTO DATA(lr_u_mtmaster).
        "입출고타입명
        IF lr_u_mtmaster->%control-movementtypename = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0020 SET movementtypename = @lr_u_mtmaster->movementtypename WHERE id = @lr_u_mtmaster->id.
        ENDIF.

        IF sy-subrc = 0 AND updateflag = 'X'.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0020h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_u_mtmaster->id
                                          action = 'U'
                                          movementtype = lr_u_mtmaster->movementtype
                                          movementtypename = lr_u_mtmaster->movementtypename
                                          delete_flag = lr_u_mtmaster->deleteflag
                                          created_by = lr_u_mtmaster->createdby
                                          created_at = lr_u_mtmaster->createdat
                                          last_changed_by = lr_u_mtmaster->lastchangedby
                                          last_changed_at = lr_u_mtmaster->lastchangedat
                                        ).
              INSERT INTO ztgsco0020h VALUES @ls_ztgsco0020h.

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

CLASS lhc_glmaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR glvcmaster RESULT result.

    METHODS beforesave FOR VALIDATE ON SAVE
      IMPORTING keys FOR glvcmaster~beforesave.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_authorizations FOR glvcmaster RESULT result.

ENDCLASS.

CLASS lhc_glmaster IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.

*   결과 행
    DATA result_line LIKE LINE OF result.
*   활성 인스턴스를 조회할 키 테이블 (활성 인스턴스 : 저장된 데이터)
    DATA keys_of_active_instances TYPE TABLE FOR INSTANCE FEATURES KEY zi_glmtvaluationclass_master.

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
      READ ENTITIES OF zi_glmtvaluationclass_master IN LOCAL MODE
            ENTITY glvcmaster
*              ALL FIELDS
              FIELDS ( matvaluationclass )
              WITH CORRESPONDING #( keys_of_active_instances )
            RESULT DATA(active_entity).

*     활성 인스턴스가 존재하면 readonly로 바꿈
      IF active_entity IS NOT INITIAL.
        result_line-%features-%field-matvaluationclass =  if_abap_behv=>fc-f-read_only .
      ELSE.
        result_line-%features-%field-matvaluationclass = if_abap_behv=>fc-f-unrestricted.
      ENDIF.

      APPEND result_line TO result.

    ENDLOOP.
  ENDMETHOD.

  METHOD beforesave.

*   메세지 처음에 전부 정리
    APPEND VALUE #(
                      %create = if_abap_behv=>mk-on
                      %element-matvaluationclass = if_abap_behv=>mk-on
                      %is_draft = if_abap_behv=>mk-on
                      id = keys[ 1 ]-id
                      %state_area = if_abap_behv=>state_area_all
                    ) TO reported-glvcmaster.

    DATA : lv_error TYPE abap_boolean.

    READ ENTITIES OF zi_glmtvaluationclass_master IN LOCAL MODE
    ENTITY glvcmaster
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_glvcmaster)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

*   유효성 체크
    SELECT glaccount, matvaluationclass
      FROM @lt_glvcmaster AS lt_chek
    INTO TABLE @DATA(lt_checktype).

    DATA:
      lr_matcher TYPE REF TO cl_abap_matcher,
      lv_success.

    DATA(lv_pattern) = '[0-9]+'.

    LOOP AT lt_checktype INTO DATA(ls_checktype).


      lr_matcher = cl_abap_matcher=>create_pcre(
                           pattern = lv_pattern
                           text    = ls_checktype-glaccount
                            ).
      lv_success = lr_matcher->match( ).

      IF  lv_success NE 'X'.
        lv_error = abap_true.
        APPEND VALUE #( %is_draft = if_abap_behv=>mk-on
                        %create = if_abap_behv=>mk-on
                        id = keys[ 1 ]-id
                        %element-glaccount = if_abap_behv=>mk-on
                        %state_area = '01'
                        %msg = new_message(
                            id = 'ZMCGSCO0010'
                            number = '005'
                            severity = if_abap_behv_message=>severity-error
                      ) ) TO reported-glvcmaster.

      ENDIF.

      CLEAR lv_success.

      lr_matcher = cl_abap_matcher=>create_pcre(
                           pattern = lv_pattern
                           text    = ls_checktype-matvaluationclass
                            ).
      lv_success = lr_matcher->match( ).

      IF lv_success NE 'X'.
        lv_error = abap_true.
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                        %is_draft = if_abap_behv=>mk-on
                        %element-matvaluationclass = if_abap_behv=>mk-on
                        id = keys[ 1 ]-id
                        %state_area = '01'
                        %msg = new_message(
                            id = 'ZMCGSCO0010'
                            number = '005'
                            severity = if_abap_behv_message=>severity-error )
                      ) TO reported-glvcmaster.

      ENDIF.
    ENDLOOP.

*   평가클래스 중복값 체크
    SELECT glaccount, matvaluationclass
    FROM ztgsco0010 AS main
    WHERE EXISTS ( SELECT glaccount, matvaluationclass
                     FROM @lt_glvcmaster AS lt_checkdata
                    WHERE lt_checkdata~matvaluationclass = main~matvaluationclass )
      AND delete_flag = ''
     INTO TABLE @DATA(lt_check).

    IF sy-subrc = 0.
      lv_error = abap_true.
      LOOP AT lt_check INTO DATA(ls_check).
        APPEND VALUE #(
                        %create = if_abap_behv=>mk-on
                        %element-matvaluationclass = if_abap_behv=>mk-on
                        %is_draft = if_abap_behv=>mk-on
                        id = keys[ 1 ]-id
                        %state_area = '01'
                        %msg = new_message(
                            id = 'ZMCGSCO0010'
                            number = '001'
                            v1 = ls_check-matvaluationclass
                            severity = if_abap_behv_message=>severity-error )
                      ) TO reported-glvcmaster.
      ENDLOOP.
    ENDIF.

    "오류 발생
    IF lv_error = abap_true.

      LOOP AT keys INTO DATA(ls_key).
        APPEND VALUE #( %create = if_abap_behv=>mk-on
                        %fail-cause = if_abap_behv=>cause-conflict
                        id = ls_key-id
                      )  TO failed-glvcmaster.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_glmtvaluationclass_mast DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_glmtvaluationclass_mast IMPLEMENTATION.

  METHOD save_modified.
    DATA : ls_ztgsco0010  TYPE ztgsco0010,
           ls_ztgsco0010h TYPE ztgsco0010h.

**********************************************************************
* Create
**********************************************************************
    IF create-glvcmaster IS NOT INITIAL.
      LOOP AT create-glvcmaster REFERENCE INTO DATA(lr_c_glvcmaster).
        ls_ztgsco0010 = VALUE #(  id = lr_c_glvcmaster->id
                                  matvaluationclass = lr_c_glvcmaster->matvaluationclass
                                  matlvaluationclasstext = lr_c_glvcmaster->matlvaluationclasstext
                                  glaccount = lr_c_glvcmaster->glaccount
                                  glaccountname = lr_c_glvcmaster->glaccountname
                                  delete_flag = lr_c_glvcmaster->deleteflag
                                  created_by = lr_c_glvcmaster->createdby
                                  created_at = lr_c_glvcmaster->createdat
                                  last_changed_by = lr_c_glvcmaster->lastchangedby
                                  last_changed_at = lr_c_glvcmaster->lastchangedat
                                ).
        INSERT INTO ztgsco0010 VALUES @ls_ztgsco0010.

        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0010h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_c_glvcmaster->id
                                          action = 'C'
                                          matvaluationclass = lr_c_glvcmaster->matvaluationclass
                                          matlvaluationclasstext = lr_c_glvcmaster->matlvaluationclasstext
                                          glaccount = lr_c_glvcmaster->glaccount
                                          glaccountname = lr_c_glvcmaster->glaccountname
                                          delete_flag = lr_c_glvcmaster->deleteflag
                                          created_by = lr_c_glvcmaster->createdby
                                          created_at = lr_c_glvcmaster->createdat
                                          last_changed_by = lr_c_glvcmaster->lastchangedby
                                          last_changed_at = lr_c_glvcmaster->lastchangedat
                                        ).
              INSERT INTO ztgsco0010h VALUES @ls_ztgsco0010h.

            CATCH cx_uuid_error INTO DATA(exc_c).
              DATA(excc) = exc_c.
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Delete
**********************************************************************
    IF delete-glvcmaster IS NOT INITIAL.
      SELECT *
        FROM ztgsco0010
        WHERE id IN ( SELECT id FROM @delete-glvcmaster AS zglvcmaster )
        INTO TABLE @DATA(lr_r_glvcmaster).

      LOOP AT delete-glvcmaster REFERENCE INTO DATA(lr_d_glvcmaster).
        UPDATE ztgsco0010 SET delete_flag = 'X' WHERE id = @lr_d_glvcmaster->id.
        READ TABLE lr_r_glvcmaster WITH KEY id = lr_d_glvcmaster->id INTO DATA(lr_r_data).
        IF sy-subrc = 0.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""

          TRY.
              ls_ztgsco0010h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_r_data-id
                                          action = 'D'
                                          matvaluationclass = lr_r_data-matvaluationclass
                                          matlvaluationclasstext = lr_r_data-matlvaluationclasstext
                                          glaccount = lr_r_data-glaccount
                                          glaccountname = lr_r_data-glaccountname
                                          delete_flag = lr_r_data-delete_flag
                                          created_by = lr_r_data-created_by
                                          created_at = lr_r_data-created_at
                                          last_changed_by = lr_r_data-last_changed_by
                                          last_changed_at = lr_r_data-last_changed_at
                                        ).
              INSERT INTO ztgsco0010h VALUES @ls_ztgsco0010h.
            CATCH cx_uuid_error INTO DATA(exc_d).
              DATA(excd) = exc_d.
          ENDTRY.

        ENDIF.
      ENDLOOP.
    ENDIF.

**********************************************************************
* Update
**********************************************************************
    IF update-glvcmaster IS NOT INITIAL.

      DATA : updateflag TYPE abap_boolean.
      CLEAR updateflag.

      LOOP AT update-glvcmaster REFERENCE INTO DATA(lr_u_glvcmaster).
        "평가클래스명
        IF lr_u_glvcmaster->%control-matlvaluationclasstext = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0010 SET matlvaluationclasstext = @lr_u_glvcmaster->matlvaluationclasstext WHERE id = @lr_u_glvcmaster->id.
        ENDIF.

        "GL계정
        IF lr_u_glvcmaster->%control-glaccount = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0010 SET glaccount = @lr_u_glvcmaster->glaccount WHERE id = @lr_u_glvcmaster->id.
        ENDIF.

        "GL계정명
        IF lr_u_glvcmaster->%control-glaccountname = if_abap_behv=>mk-on.
          updateflag = 'X'.
          UPDATE ztgsco0010 SET glaccountname = @lr_u_glvcmaster->glaccountname WHERE id = @lr_u_glvcmaster->id.
        ENDIF.

        IF sy-subrc = 0 AND updateflag = 'X'.
          """"""""""""""""""""""""""""""""""""""""""""""
          "" History Table Save
          """"""""""""""""""""""""""""""""""""""""""""""
          TRY.
              ls_ztgsco0010h = VALUE #(  id = cl_system_uuid=>create_uuid_x16_static(  )
                                          refhead = lr_u_glvcmaster->id
                                          action = 'U'
                                          matvaluationclass = lr_u_glvcmaster->matvaluationclass
                                          matlvaluationclasstext = lr_u_glvcmaster->matlvaluationclasstext
                                          glaccount = lr_u_glvcmaster->glaccount
                                          glaccountname = lr_u_glvcmaster->glaccountname
                                          delete_flag = lr_u_glvcmaster->deleteflag
                                          created_by = lr_u_glvcmaster->createdby
                                          created_at = lr_u_glvcmaster->createdat
                                          last_changed_by = lr_u_glvcmaster->lastchangedby
                                          last_changed_at = lr_u_glvcmaster->lastchangedat
                                        ).
              INSERT INTO ztgsco0010h VALUES @ls_ztgsco0010h.

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

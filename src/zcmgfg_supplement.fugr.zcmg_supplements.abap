FUNCTION zcmg_supplements.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SUPPLEMENTS) TYPE  ZCMGTT_SUPPL
*"     REFERENCE(IV_OP_TYPE) TYPE  ZDE_FLAG
*"  EXPORTING
*"     REFERENCE(EV_UPDATED) TYPE  ZDE_FLAG
*"----------------------------------------------------------------------
  CHECK NOT it_supplements IS INITIAL.

  CASE iv_op_type.
    WHEN 'C'. " Create
      INSERT zcmg_booksuppl FROM TABLE @it_supplements.
    WHEN 'U'.
      UPDATE zcmg_booksuppl FROM TABLE @it_supplements.
    WHEN 'D'.
      DELETE zcmg_booksuppl FROM TABLE @it_supplements.
  ENDCASE.

  IF sy-subrc EQ 0.
    ev_updated = abap_true.
  ENDIF.

ENDFUNCTION.

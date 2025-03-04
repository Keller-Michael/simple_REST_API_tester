CLASS ltc_simple_rest_api_tester DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS postman_echo_get_ok FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltc_simple_rest_api_tester IMPLEMENTATION.

  METHOD postman_echo_get_ok.
    DATA(cut) = NEW zcl_simple_rest_api_tester( ).

    cut->uri = 'https://postman-echo.com/get'.

    cut->request_content =  VALUE #( first_name = 'Max'
                                     last_name  = 'Mustermann'
                                     email      = 'max.mustermann@example.com' ).

    cut->json_name_mappings = VALUE #( ( abap = 'FIRST_NAME'
                                         json = 'first_name' ) ).

    cut->execute( ).

    cl_abap_unit_assert=>assert_equals( act = cut->response_content-url
                                        exp = 'https://postman-echo.com/get' ).
  ENDMETHOD.

ENDCLASS.

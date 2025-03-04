"! Class for very easy consumption of a REST API when quickly building a prototype.
"! Not intended for productive applications.
"! For testing, first adapt the class to your own requirements. Then either execute the class and view the
"! console output or create an object of the class and call the "execute" method, then process the content of the
"! public attribute RESPONSE_CONTENT.
CLASS zcl_simple_rest_api_tester DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    TYPES: BEGIN OF ty_request_content,
             first_name TYPE string,
             last_name  TYPE string,
             email      TYPE string,
           END OF ty_request_content.

    TYPES: BEGIN OF ty_response_content,
             url TYPE string,
           END OF ty_response_content.

    DATA uri TYPE string VALUE `https://postman-echo.com/get`.
    DATA method TYPE if_web_http_client=>method VALUE if_web_http_client=>get.
    DATA destination TYPE REF TO if_http_destination.
    DATA client TYPE REF TO if_web_http_client.
    DATA request TYPE REF TO if_web_http_request.
    DATA request_content TYPE ty_request_content.
    DATA json_name_mappings TYPE /ui2/cl_json=>name_mappings.
    DATA response TYPE REF TO if_web_http_response.
    DATA response_content TYPE ty_response_content.

    METHODS constructor RAISING cx_web_http_client_error.

    METHODS execute RAISING cx_web_http_client_error.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_simple_rest_api_tester IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TRY.
        execute( ).
      CATCH cx_web_http_client_error.
        out->write( 'HTTP error' ).
    ENDTRY.

    out->write( |Date & time: | &&
                |{ cl_abap_context_info=>get_system_date( ) DATE = ISO }, | &&
                |{ cl_abap_context_info=>get_system_time( ) TIME = ISO }| ).

    out->write( |URL: | && uri ).
    out->write( |HTTP request method: { method }| ).

    out->write( '---' ).

    out->write( |HTTP response status code: { response->get_status( )-code }| ).
    out->write( |HTTP response status text: { response->get_status( )-reason }| ).

    out->write( '---' ).

    DATA(text) = response->get_text( ).
    out->write( text ).
  ENDMETHOD.

  METHOD constructor.
    TRY.
        destination = cl_http_destination_provider=>create_by_url( uri ).
        client = cl_web_http_client_manager=>create_by_http_destination( destination ).
      CATCH cx_web_http_client_error
            cx_http_dest_provider_error.
        RAISE EXCEPTION NEW cx_web_http_client_error( ).
    ENDTRY.
  ENDMETHOD.

  METHOD execute.
    request = client->get_http_request( ).
    request->set_content_type( 'application/json' ).

    TRY.
        DATA(content_as_json) = /ui2/cl_json=>serialize( data          = request_content
                                                         name_mappings = json_name_mappings ).

        request->set_text( content_as_json ).
        response = client->execute( method ).
      CATCH cx_web_http_client_error
            cx_web_message_error.
        RAISE EXCEPTION NEW cx_web_http_client_error( ).
    ENDTRY.

    /ui2/cl_json=>deserialize(
                   EXPORTING
                     json = response->get_text( )
                   CHANGING
                     data = response_content ).
  ENDMETHOD.

ENDCLASS.

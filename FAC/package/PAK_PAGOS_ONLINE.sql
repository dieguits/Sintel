CREATE OR REPLACE PACKAGE fac.pak_pagos_online IS
    /*
        VERSION:    1.0
        AUTOR:      DIEGO A PEREZ
        COPYRIGHT:  D4P
        DESCRIPCION:

        HISTORIAL DE CAMBIOS
        AUTOR       FECHA             ACTIVIDAD
        ---------   ----------------  ----------------------------------
        D4P         23/06/2016        Creacion Paquete.
        D4P         23/06/2016        Creacion registra_pago.
        D4P         23/06/2016        Creacion es_sucursal.
        D4P         23/06/2016        Creacion saldo_a_favor.
        D4P         23/06/2016        Creacion saldo_cliente.
        D4P         21/12/2016        Creacion registra_pago_coopenesa.
        D4P         21/12/2016        Creacion registra_pago_web.
    */

    err_origen        VARCHAR2 (50);
    err_descripcion   VARCHAR (300);

    TYPE datos_linea IS RECORD
    (
        fecha_limite_pago     DATE,
        nombre_razon_social   cliente.nombre_razon_social%TYPE,
        valor_cupon1          NUMBER (14, 2),
        valor_cupon2          NUMBER (14, 2),
        valor_cupon3          NUMBER (14 ,2)
    );

    PROCEDURE registra_pago (
        p_nro_linea         IN     transaccion.tipo_linea_reportado%TYPE,
        p_tipo_linea        IN     transaccion.tipo_linea_aplicado%TYPE,
        p_tipo_pago         IN     fac.transaccion.cod_forma_pago%TYPE,
        p_valor_pago        IN     NUMBER,
        p_fecha_pago        IN     DATE,
        p_cod_medio_pago    IN     transaccion.cod_medio_pago%TYPE,
        p_cod_banco         IN     transaccion.cod_sitio_banco%TYPE,
        p_cod_sucursal      IN     transaccion.cod_sucursal_caja%TYPE,
        p_nro_doc           IN     transaccion.nro_doc%TYPE,
        p_obs_pago          IN     transaccion.observacion%TYPE,
        p_seq_transaccion      OUT transaccion.seq_transaccion%TYPE,
        respuesta              OUT VARCHAR2);

    FUNCTION es_sucursal (p_cod_banco      IN parametro_recaudo.banco%TYPE,
                          p_cod_sucursal   IN parametro_recaudo.sucursal%TYPE,
                          p_nro_doc        IN parametro_recaudo.doc_ini%TYPE)
        RETURN VARCHAR2;

    FUNCTION saldo_a_favor (p_seq_linea IN linea.seq_linea%TYPE)
        RETURN NUMBER;

    PROCEDURE saldo_cliente (
        p_linea               IN     linea_cuenta.linea%TYPE,
        p_tipo_linea          IN     linea_cuenta.tipo_linea%TYPE,
        fecha_limite_pago        OUT DATE,
        nro_factura              OUT VARCHAR,
        nombre_razon_social      OUT cliente.nombre_razon_social%TYPE,
        valor_cupon1             OUT NUMBER,
        valor_cupon2             OUT NUMBER,
        valor_cupon3             OUT NUMBER,
        saldo_vencido            OUT NUMBER,
        saldo_favor              OUT NUMBER);

    PROCEDURE registra_pago_coopenesa (
        p_nro_linea         IN     transaccion.tipo_linea_reportado%TYPE,
        p_tipo_linea        IN     transaccion.tipo_linea_aplicado%TYPE,
        p_valor_pago        IN     NUMBER,
        p_fecha_pago        IN     DATE,
        s_seq_transaccion      OUT transaccion.seq_transaccion%TYPE,
        respuesta              OUT VARCHAR2);

    PROCEDURE registra_pago_web (
        p_compania_id       IN     VARCHAR2,
        p_nro_linea         IN     linea_cuenta.linea%TYPE,
        p_tipo_linea        IN     linea_cuenta.tipo_linea%TYPE,
        p_valor_pago        IN     NUMBER,
        p_fecha_pago        IN     DATE,
        s_seq_transaccion      OUT transaccion.seq_transaccion%TYPE,
        p_codigo               OUT VARCHAR2,
        respuesta              OUT VARCHAR2);

END pak_pagos_online;
/



-- End of DDL Script for Package FAC.PAK_PAGOS_ONLINE


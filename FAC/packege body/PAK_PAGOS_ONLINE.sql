CREATE OR REPLACE PACKAGE BODY fac.pak_pagos_online IS
    
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
        respuesta              OUT VARCHAR2) IS
        p_seq_linea              linea_cuenta.seq_linea%TYPE;
        p_atraso                 linea_cuenta.nro_mes_atraso%TYPE;
        obs_pago                 fac.transaccion.observacion%TYPE;
        forma_pago               fac.transaccion.cod_forma_pago%TYPE;
        ciclo_linea              fac.linea_cuenta.cod_ciclo%TYPE;
        pago_inmediato           VARCHAR2 (1) := NULL;
        pago_pendiente_aplicar   VARCHAR2 (2) := 'P';
        ciclo_en_proceso         BOOLEAN;
        entra                    BOOLEAN := FALSE;
        p_id_abono               NUMBER;
        p_fecha_recaudo          DATE;
        pago                     tipo_transaccion.cod_tipo_trans%TYPE := 'PG';
    BEGIN

        IF p_tipo_linea IS NULL OR p_nro_linea IS NULL THEN
            respuesta := 'Debe digitar los datos de linea y tipo de linea';
            entra := TRUE;
        END IF;

        IF entra THEN
            IF es_sucursal (p_cod_banco, p_cod_sucursal, p_nro_doc) = 'N' THEN
                respuesta := 'No existe el banco o la numeracion de la sucursal es incorrecta';
            END IF;
        ELSE

            p_seq_linea := ul.getseqlinea (p_nro_linea, p_tipo_linea);
            p_atraso := fac.atraso2 (p_nro_linea, p_tipo_linea);
            p_fecha_recaudo := fac.fecha_recaudo_web;
            ciclo_linea := ul.getciclo (p_nro_linea, p_tipo_linea);
            ciclo_en_proceso := fac.pak_ciclo.ciclo_en_proceso (ciclo_linea);

            IF NOT ciclo_en_proceso THEN
                -- Efectua el preprocesamiento del saldo, antes del ingreso del pago
                fac.pak_pagos.proceso_previo_ins_pago (
                    p_linea              => p_nro_linea,
                    p_tipo_linea         => p_tipo_linea,
                    p_seq_linea          => p_seq_linea,
                    p_vlr_trans          => p_valor_pago,
                    p_banco              => p_cod_banco,
                    p_seq_estudio_fact   => NULL,
                    p_cod_tipo_trans     => pago,
                    id_abono             => p_id_abono);

                forma_pago := pago_inmediato;
            ELSE
                forma_pago := pago_pendiente_aplicar;
            END IF;

            fac.u_transaccion.instransaccion (
                pcod_tipo_trans         => pago,
                plinea_reportado        => p_nro_linea,
                ptipo_linea_reportado   => p_tipo_linea,
                pfecha_proceso          => p_fecha_pago,
                pvlr_trans              => p_valor_pago,
                paplicar                => 'S',
                paplicada               => 'N',
                pcod_sitio_banco        => p_cod_banco,
                pcod_sucursal_caja      => p_cod_sucursal,
                pcod_medio_pago         => p_cod_medio_pago,
                pnro_doc                => p_nro_doc,
                pfecha_recaudo          => p_fecha_recaudo,
                pcod_oficial_banco      => p_cod_banco,
                pobservacion            => p_obs_pago,
                pnro_mes_atraso         => p_atraso,
                pcod_ciclo              => ciclo_linea,
                pcod_forma_pago         => forma_pago);

            -- Si se trata de un abono a la deuda, restablece los saldos pendientes
            -- OJO: No se hace uso de la funcion fac.pak_financiacion2.es_abono_deuda en este
            -- punto, pues a estas alturas ya se ha puesto la fecha_pago a la tabla historico_financiacion
            -- La vble :b_det.id_abono es inicializada en el pre-insert del bloque b_det
            IF NOT ciclo_en_proceso AND p_id_abono != 0 THEN
                fac.temporal_impresion_abonos_xp.restablecer_saldos (
                    id_in          => p_id_abono,
                    p_linea        => p_nro_linea,
                    p_tipo_linea   => p_tipo_linea);
            END IF;
        END IF;
    -- inslogpagos (p, nota);                                                      -- bitacora
    END registra_pago;


    FUNCTION es_sucursal (p_cod_banco      IN parametro_recaudo.banco%TYPE,
                          p_cod_sucursal   IN parametro_recaudo.sucursal%TYPE,
                          p_nro_doc        IN parametro_recaudo.doc_ini%TYPE)
        RETURN VARCHAR2 IS
        CURSOR c_datos  IS
            SELECT 'S'
              FROM parametro_recaudo p
             WHERE     p.banco = p_cod_banco
                   AND p.sucursal = p_cod_sucursal
                   AND p_nro_doc BETWEEN p.doc_ini AND p.doc_fin;

        existe   VARCHAR2 (1);
    BEGIN
        OPEN c_datos;

        FETCH c_datos INTO existe;

        CLOSE c_datos;

        RETURN NVL (existe, 'N');
    END es_sucursal;

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
        saldo_favor              OUT NUMBER
        --total_cupon1             OUT NUMBER,
        --total_cupon2             OUT NUMBER
        ) IS

        CURSOR c_datos  IS
              SELECT f.fecha_limite_pago,
                     c.nombre_razon_social,
                     --Tiquet 7109
                     --Si un cliente posee una financiacion NO efectiva del dia anterior
                     --visualiza el valor de la cuota inicial
                     fac.pak_listas_cpt.valor_cupon1(p_linea=> lc.linea, p_tipo_linea=> lc.tipo_linea) cupon1,
                     SUM(ROUND(DECODE(fac.pak_listas_cpt.es_concepto_tarifa_prima(s.cod_cpt), 'N', s.vlr_sdo_fact + s.vlr_sdo_refc,0)/ 10)* 10) cupon2,
                     CASE WHEN fac.cuota_inicial (lc.linea) > 0 THEN
                            SUM (fac.cuota_inicial (lc.linea))
                          ELSE
                            SUM (s.vlr_sdo_fact + s.vlr_sdo_refc)
                     END cupon3
                FROM linea_cuenta lc,
                     cliente c,
                     concepto_cobro cc,
                     fecha_ciclo f,
                     saldo s
               WHERE lc.vlr_sdo_fact + lc.vlr_sdo_refc - lc.vlr_sdo_a_favor > 0
                 AND lc.ced_nit_resp = c.ced_nit
                 AND lc.cod_ciclo = f.cod_ciclo
                 AND s.cod_cpt = cc.cod_cpt
                 AND lc.seq_linea = s.seq_linea
                 AND f.ano_proceso = TO_CHAR (SYSDATE, 'yyyy')
                 AND f.mes_proceso = '10'--TO_CHAR (SYSDATE, 'mm')
                      -- CJI 06/06/06 excluir las pertenecientes a Telebucaramanga
                 AND lc.ced_nit_resp <> get_param ('NIT', 'C')
                 AND lc.linea = p_linea --6325852
                     -- Mayo 29/2008 Ticket 3907 No incluye lineas tipo C que existan tipo L
                 AND (lc.linea, lc.tipo_linea) NOT IN (SELECT linea,
                                                              tipo_linea
                                                         FROM linea_cuenta l1
                                                        WHERE tipo_linea = 'C'
                                                          AND l1.linea = lc.linea
                                                          AND EXISTS (SELECT 'x'
                                                                        FROM linea_cuenta l2
                                                                       WHERE tipo_linea = 'L'
                                                                         AND l2.linea = l1.linea))
                 AND (lc.nro_cta_cte IS NULL OR (lc.nro_cta_cte IS NOT NULL AND lc.tipo_cta_cte != 'C'))
                     AND NOT EXISTS (SELECT 'x'
                                       FROM gestion_cartera gc,
                                            responsable_gestion rg
                                      WHERE gc.seq_linea = lc.seq_linea
                                        AND gc.responsable = rg.cod_func
                                        AND gc.retiro IS NULL
                                        AND rg.clase = 'A')
            GROUP BY lc.linea, lc.tipo_linea ,f.fecha_limite_pago, c.nombre_razon_social;

        t_datos_linea   datos_linea;
        linea           linea_cuenta.linea%TYPE;
        ano             NUMBER (4) := TO_CHAR (SYSDATE, 'YYYY');
        mes             NUMBER (2) := TO_CHAR (SYSDATE, 'MM');
    BEGIN
        OPEN c_datos;

        FETCH c_datos INTO t_datos_linea;

        linea := p_linea;
        fecha_limite_pago := t_datos_linea.fecha_limite_pago;
        nombre_razon_social := t_datos_linea.nombre_razon_social;
        valor_cupon1 := NVL (t_datos_linea.valor_cupon1, 0);
        valor_cupon2 := NVL (t_datos_linea.valor_cupon2, 0);
        valor_cupon3 := NVL (t_datos_linea.valor_cupon3, 0);

        saldo_favor := saldo_a_favor ( p_seq_linea   => ul.getseqlinea (p_linea, p_tipo_linea));

        --total_cupon1 := valor_cupon1 - saldo_favor;
        --total_cupon2 := valor_cupon2 - saldo_favor;

        CLOSE c_datos;

        nro_factura := fac.pak_historico_facturas.nrofactura (plinea        => p_linea,
                                                              ptipo_linea   => p_tipo_linea,
                                                              pano          => ano,
                                                              pmes          => mes);
    END;

    FUNCTION saldo_a_favor (p_seq_linea IN linea.seq_linea%TYPE)
        RETURN NUMBER IS
        CURSOR c_saldo  IS
            SELECT vlr_sdo_a_favor
              FROM linea_cuenta
             WHERE seq_linea = p_seq_linea;

        valor   NUMBER (14, 2);
    BEGIN
        OPEN c_saldo;

        FETCH c_saldo INTO valor;

        CLOSE c_saldo;

        RETURN NVL (valor, 0);
    END;

    PROCEDURE registra_pago_coopenesa (
        p_nro_linea         IN     transaccion.tipo_linea_reportado%TYPE,
        p_tipo_linea        IN     transaccion.tipo_linea_aplicado%TYPE,
        p_valor_pago        IN     NUMBER,
        p_fecha_pago        IN     DATE,
        s_seq_transaccion      OUT transaccion.seq_transaccion%TYPE,
        respuesta              OUT VARCHAR2) IS

        tipo_pago            fac.transaccion.cod_forma_pago%TYPE;
        cod_medio_pago       transaccion.cod_medio_pago%TYPE;
        cod_banco            transaccion.cod_sitio_banco%TYPE;
        cod_sucursal         transaccion.cod_sucursal_caja%TYPE;
        nro_doc              transaccion.nro_doc%TYPE := 1122;
        obs_pago             transaccion.observacion%TYPE := 'Pago online Coopenesa';

        efectivo             medio_pago.cod_medio_pago%TYPE := 1;
        bancolombia          sitio_banco.cod_sitio_banco%TYPE := 31;
        ahorro_inversiones   sucursal_caja.cod_sucursal_caja%TYPE := 314;
    BEGIN
        cod_medio_pago := efectivo;
        cod_banco := bancolombia;
        cod_sucursal := ahorro_inversiones;

        fac.pak_pagos_online.registra_pago (
            p_nro_linea         => p_nro_linea,
            p_tipo_linea        => p_tipo_linea,
            p_tipo_pago         => tipo_pago,
            p_valor_pago        => p_valor_pago,
            p_fecha_pago        => p_fecha_pago,
            p_cod_medio_pago    => cod_medio_pago,
            p_cod_banco         => cod_banco,
            p_cod_sucursal      => cod_sucursal,
            p_nro_doc           => nro_doc,
            p_obs_pago          => obs_pago,
            p_seq_transaccion   => s_seq_transaccion,
            respuesta           => respuesta);


    EXCEPTION WHEN OTHERS THEN
        --p_codigo := 99;
        respuesta := SUBSTR('Error de base de datos: ' || SQLCODE || '. ' || SQLERRM, 1, 1000);
    END registra_pago_coopenesa;

    PROCEDURE registra_pago_web (
        p_compania_id       IN     VARCHAR2,
        p_nro_linea         IN     linea_cuenta.linea%TYPE,
        p_tipo_linea        IN     linea_cuenta.tipo_linea%TYPE,
        p_valor_pago        IN     NUMBER,
        p_fecha_pago        IN     DATE,
        s_seq_transaccion      OUT transaccion.seq_transaccion%TYPE,
        p_codigo               OUT VARCHAR2,
        respuesta              OUT VARCHAR2) IS

    BEGIN

        fac.pak_pagos_online.registra_pago_coopenesa(p_nro_linea=> p_nro_linea,
                                                     p_tipo_linea=> p_tipo_linea,
                                                     p_valor_pago=> p_valor_pago,
                                                     p_fecha_pago=> p_fecha_pago,
                                                     s_seq_transaccion=> s_seq_transaccion,
                                                     respuesta=> respuesta);
        p_codigo := 'OK';
        respuesta := 'Pago realizado exitosamente.';
        DBMS_OUTPUT.Put_Line('Paso bien el pago de la linea ' || p_nro_linea);

    EXCEPTION WHEN OTHERS THEN
        p_codigo := 99;
        respuesta := SUBSTR('Error de base de datos: ' || SQLCODE || '. ' || SQLERRM, 1, 1000);
    END registra_pago_web;
END pak_pagos_online;
/



-- End of DDL Script for Package Body FAC.PAK_PAGOS_ONLINE


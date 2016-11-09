CREATE OR REPLACE PACKAGE bsme.pak_servicio IS
    /*
    VERSION:    1.0
    AUTOR:      DIEGO A PEREZ
    COPYRIGHT:  D4P
    DESCRIPCION:

    HISTORIAL DE CAMBIOS
    AUTOR       FECHA             ACTIVIDAD
    ---------   ----------------  ----------------------------------
    D4P         12/04/2016        Creacion funcion archivo
    D4P         01/04/2016        Creacion de funcion cod_estado
    D4P         31/03/2016        Creacion package 2do nivel registra_servicio
    D4P         31/03/2016        Cambio en procedure inserta, se agrega campo de devolucion
    D4P         31/03/2016        Creacion procedure actualiza
    D4P         29/03/2016        Creacion procedure actualiza_estado
    D4P         17/03/2016        Eliminar del inserta el seq_nro_servicio y agregar el usuario
    D4P         03/03/2016        Creacion del paquete
    D4P         03/03/2016        Creacion function nro_solicitud
    D4P         03/03/2016        Creacion procedure inserta
    */
    err_origen        VARCHAR2 (50);
    err_descripcion   VARCHAR (300);

    FUNCTION nro_solicitud (p_nro_servicio IN servicio.seq_nro_servicio%TYPE)
        RETURN servicio.seq_nro_solicitud%TYPE;

    --Funcion para saber el estado actual del servicio.
    FUNCTION cod_estado (p_nro_servicio IN servicio.seq_nro_servicio%TYPE)
        RETURN servicio.cod_estado%TYPE;

    --Funcion para obtener el nombre del archivo del servicio.
    FUNCTION archivo (p_seq_nro_servicio IN servicio.seq_nro_servicio%TYPE)
        RETURN bsme.servicio.archivo%TYPE;

    PROCEDURE inserta (
        p_nro_solicitud       IN     servicio.seq_nro_solicitud%TYPE,
        p_cod_tipo_servicio   IN     servicio.cod_tipo_servicio%TYPE,
        p_cod_estado          IN     servicio.cod_estado%TYPE,
        p_fecha_solicita      IN     servicio.fecha_solicita%TYPE,
        p_valor               IN     servicio.valor%TYPE,
        p_cantidad            IN     servicio.cantidad%TYPE,
        p_fecha_servicio      IN     servicio.fecha_servicio%TYPE,
        p_nro_factura         IN     servicio.nro_factura%TYPE,
        p_comision            IN     servicio.comision%TYPE,
        p_fecha_radicado      IN     servicio.fecha_radicado%TYPE,
        p_observaciones       IN     servicio.observaciones%TYPE,
        p_cod_usr_solicita    IN     servicio.cod_usr_solicita%TYPE,
        p_activo              IN     servicio.activo%TYPE,
        p_usuario             IN     servicio.usr_creacion%TYPE,
        p_archivo             IN     servicio.archivo%TYPE,
        p_seq_nro_servicio       OUT servicio.seq_nro_servicio%TYPE);

    -- Actualiza el estado de la solicitud
    PROCEDURE actualiza_estado (
        p_seq_nro_solicitud   IN servicio.seq_nro_solicitud%TYPE,
        p_seq_nro_servicio    IN servicio.seq_nro_servicio%TYPE,
        p_cod_estado          IN servicio.cod_estado%TYPE);

    --Inserta el servicio y el tramite del servicio
    PROCEDURE registra_servicio (
        p_seq_nro_servicio      IN OUT servicio.seq_nro_servicio%TYPE,
        p_seq_nro_solicitud     IN     servicio.seq_nro_solicitud%TYPE,
        p_cod_tipo_servicio     IN     servicio.cod_tipo_servicio%TYPE,
        p_cod_estado            IN     servicio.cod_estado%TYPE,
        p_fecha_solicita        IN     servicio.fecha_solicita%TYPE,
        p_valor                 IN     servicio.valor%TYPE,
        p_cantidad              IN     servicio.cantidad%TYPE,
        p_fecha_servicio        IN     servicio.fecha_servicio%TYPE,
        p_nro_factura           IN     servicio.nro_factura%TYPE,
        p_comision              IN     servicio.comision%TYPE,
        p_fecha_radicado        IN     servicio.fecha_radicado%TYPE,
        p_observaciones         IN     servicio.observaciones%TYPE,
        p_cod_usr_solicita      IN     servicio.cod_usr_solicita%TYPE,
        p_activo                IN     servicio.activo%TYPE,
        p_usuario               IN     servicio.usr_creacion%TYPE,
        p_archivo               IN     servicio.archivo%TYPE,
        p_observacion_tramite   IN     servicio_tramite.obs_tramite%TYPE,
        p_mensaje                  OUT VARCHAR2);

    --Actualiza el servicio
    PROCEDURE actualiza (
        p_seq_nro_servicio    IN servicio.seq_nro_servicio%TYPE,
        p_seq_nro_solicitud   IN servicio.seq_nro_solicitud%TYPE,
        p_cod_tipo_servicio   IN servicio.cod_tipo_servicio%TYPE,
        p_cod_estado          IN servicio.cod_estado%TYPE,
        --p_fecha_solicita      IN servicio.fecha_solicita%TYPE,
        p_valor               IN servicio.valor%TYPE,
        p_cantidad            IN servicio.cantidad%TYPE,
        p_fecha_servicio      IN servicio.fecha_servicio%TYPE,
        p_nro_factura         IN servicio.nro_factura%TYPE,
        p_comision            IN servicio.comision%TYPE,
        p_fecha_radicado      IN servicio.fecha_radicado%TYPE,
        p_observaciones       IN servicio.observaciones%TYPE,
        --p_cod_usr_solicita    IN servicio.cod_usr_solicita%TYPE,
        p_activo              IN servicio.activo%TYPE,
        p_usuario             IN servicio.usr_ult_modificacion%TYPE,
        p_archivo             IN servicio.archivo%TYPE);
END pak_servicio;
/

-- Grants for Package
GRANT EXECUTE ON bsme.pak_servicio TO sintel_actualizacion
/


-- End of DDL Script for Package BSME.PAK_SERVICIO


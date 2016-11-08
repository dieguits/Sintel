CREATE TABLE bsme.servicio
    (seq_nro_servicio               NUMBER NOT NULL,
    seq_nro_solicitud              NUMBER NOT NULL,
    cod_tipo_servicio              VARCHAR2(8 BYTE) NOT NULL,
    cod_estado                     VARCHAR2(4 BYTE) NOT NULL,
    fecha_solicita                 DATE NOT NULL,
    valor                          NUMBER(14,2) NOT NULL,
    cantidad                       VARCHAR2(8 BYTE),
    fecha_servicio                 DATE NOT NULL,
    nro_factura                    VARCHAR2(25 BYTE),
    comision                       NUMBER(14,2),
    fecha_radicado                 DATE,
    observaciones                  VARCHAR2(4000 BYTE),
    cod_usr_solicita               VARCHAR2(3 BYTE) NOT NULL,
    activo                         VARCHAR2(1 BYTE) NOT NULL,
    usr_creacion                   VARCHAR2(3 BYTE) NOT NULL,
    fecha_creacion                 DATE NOT NULL,
    usr_ult_modificacion           VARCHAR2(3 BYTE) NOT NULL,
    fecha_ult_modificacion         DATE NOT NULL,
    archivo                        VARCHAR2(100 BYTE))
  TABLESPACE  datos1m
/

-- Grants for Table
GRANT DELETE ON bsme.servicio TO sintel_actualizacion
/
GRANT INSERT ON bsme.servicio TO sintel_actualizacion
/
GRANT SELECT ON bsme.servicio TO soporte_informatico
/
GRANT SELECT ON bsme.servicio TO sintel_actualizacion
/
GRANT SELECT ON bsme.servicio TO sintel_consulta
/
GRANT UPDATE ON bsme.servicio TO sintel_actualizacion
/




-- Comments for BSME.SERVICIO

COMMENT ON TABLE bsme.servicio IS 'Esta tabla contendra el resumen de todos los servicios generados o solicitados para cada una de las solicitudes.'
/
COMMENT ON COLUMN bsme.servicio.activo IS 'Indicador de habilitado del registro.'
/
COMMENT ON COLUMN bsme.servicio.archivo IS 'Archivo que se adjunta a la solicitud.'
/
COMMENT ON COLUMN bsme.servicio.cantidad IS 'Cantidad de veces que se generara el servicio.'
/
COMMENT ON COLUMN bsme.servicio.cod_estado IS 'Estado del servicio. (Solicitado, Aprobado, Verificar, Pagado).'
/
COMMENT ON COLUMN bsme.servicio.cod_tipo_servicio IS 'Tipo de servicio.'
/
COMMENT ON COLUMN bsme.servicio.cod_usr_solicita IS 'Codigo del usuario que solicita el servicio.'
/
COMMENT ON COLUMN bsme.servicio.comision IS 'Comision para casos de restaurante o impuesto.'
/
COMMENT ON COLUMN bsme.servicio.fecha_creacion IS 'Fecha creacion del registro'
/
COMMENT ON COLUMN bsme.servicio.fecha_radicado IS 'Fecha del radicado de la factura.'
/
COMMENT ON COLUMN bsme.servicio.fecha_servicio IS 'Fecha en que arranca en ejecucion el servicio.'
/
COMMENT ON COLUMN bsme.servicio.fecha_solicita IS 'Fecha en que se genera la solicitud.'
/
COMMENT ON COLUMN bsme.servicio.fecha_ult_modificacion IS 'Fecha ultima modificacion'
/
COMMENT ON COLUMN bsme.servicio.nro_factura IS 'Numero de la factura cuando se radica.'
/
COMMENT ON COLUMN bsme.servicio.observaciones IS 'Observaciones que pueda tener el servicio.'
/
COMMENT ON COLUMN bsme.servicio.seq_nro_servicio IS 'Numero secuencial del servicio.'
/
COMMENT ON COLUMN bsme.servicio.seq_nro_solicitud IS 'Numero de la solicitud.'
/
COMMENT ON COLUMN bsme.servicio.usr_creacion IS 'Usuario creacion del registro'
/
COMMENT ON COLUMN bsme.servicio.usr_ult_modificacion IS 'Usuario ultima modificacion'
/
COMMENT ON COLUMN bsme.servicio.valor IS 'Valor de la solicitud.'
/

-- End of DDL Script for Table BSME.SERVICIO


from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0009_producto_paquete_nullable'),
    ]

    operations = [
        # ── CLIENTES: curp y domicilio fiscal ──────────────────────────────
        migrations.RunSQL(
            sql=[
                # Personas físicas (llevan CURP + domicilio)
                "UPDATE cliente SET curp='MALC850312HBCRTL03', domicilio='Av. Revolución 1450, Col. Centro, Tijuana, BC, C.P. 22000' WHERE numero=1",
                "UPDATE cliente SET curp='ROTM900615MDFDRR04', domicilio='Calle Sexta 320, Col. Cacho, Tijuana, BC, C.P. 22010' WHERE numero=2",
                "UPDATE cliente SET curp='HERJ780923HBCRMR05', domicilio='Calle Álamo 88, Col. Sanchez Taboada, Tijuana, BC, C.P. 22010' WHERE numero=4",
                "UPDATE cliente SET curp='GASA950204MBCRCN06', domicilio='Paseo de los Héroes 10289, Col. Zona Río, Tijuana, BC, C.P. 22010' WHERE numero=6",
                "UPDATE cliente SET curp='PEML820717HBCRZN07', domicilio='Calle Mina 705, Col. Centro, Mexicali, BC, C.P. 21000' WHERE numero=8",
                "UPDATE cliente SET curp='FUCR930930MBCNSN08', domicilio='Calle Reforma 220, Col. Nueva, Mexicali, BC, C.P. 21100' WHERE numero=10",
                "UPDATE cliente SET curp='OCVJ980418HBCCHL09', domicilio='Blvd. Costero 1800, Col. Playas, Tijuana, BC, C.P. 22200' WHERE numero=11",
                "UPDATE cliente SET curp='VARA850204HDFLLZ10', domicilio='Av. Tecnológico 800, Col. El Pípila, Tijuana, BC, C.P. 22040' WHERE numero=12",
                "UPDATE cliente SET curp='SAEM950521HBCLCV11', domicilio='Av. Presidente Juárez 2200, Col. Obrera, Tijuana, BC, C.P. 22030' WHERE numero=14",
                "UPDATE cliente SET curp='CAOA470923HFRSNN12', domicilio='Calle Madero 110, Col. Centro, Tijuana, BC, C.P. 22000' WHERE numero=16",
                # Personas morales (solo domicilio, sin CURP)
                "UPDATE cliente SET domicilio='Blvd. Agua Caliente 4558, Col. Aviación, Tijuana, BC, C.P. 22014' WHERE numero=3",
                "UPDATE cliente SET domicilio='Blvd. Díaz Ordaz 12300, Parque Ind. El Florido, Tijuana, BC, C.P. 22235' WHERE numero=5",
                "UPDATE cliente SET domicilio='Av. Industrial 5600, Parque Ind. Pacífico, Tijuana, BC, C.P. 22550' WHERE numero=7",
                "UPDATE cliente SET domicilio='Av. de la Industria 900, Col. Cuauhtémoc, Mexicali, BC, C.P. 21259' WHERE numero=9",
                "UPDATE cliente SET domicilio='Calle del Puerto 340, Col. Zona Norte, Ensenada, BC, C.P. 22800' WHERE numero=13",
                "UPDATE cliente SET domicilio='Blvd. Independencia 4500, Parque Ind. Nueva Tijuana, Tijuana, BC, C.P. 22435' WHERE numero=15",
            ],
            reverse_sql=[
                "UPDATE cliente SET curp=NULL, domicilio=NULL WHERE numero IN (1,2,4,6,8,10,11,12,14,16)",
                "UPDATE cliente SET domicilio=NULL WHERE numero IN (3,5,7,9,13,15)",
            ],
        ),
        # ── PEDIMENTOS: incoterm, tipo_cambio, pais_destino, medio_transporte
        migrations.RunSQL(
            sql=[
                "UPDATE pedimento SET incoterm='FOB', tipo_cambio=17.85, pais_destino='México',         medio_transporte='Terrestre' WHERE numero_pedimento='24 01 3991 4 000001' AND incoterm IS NULL",
                "UPDATE pedimento SET incoterm='CIF', tipo_cambio=18.10, pais_destino='Estados Unidos', medio_transporte='Aéreo'     WHERE numero_pedimento='24 02 3991 4 000002' AND incoterm IS NULL",
                "UPDATE pedimento SET incoterm='DAP', tipo_cambio=17.65, pais_destino='México',         medio_transporte='Terrestre' WHERE numero_pedimento='24 03 3991 4 000003' AND incoterm IS NULL",
                "UPDATE pedimento SET incoterm='EXW', tipo_cambio=18.30, pais_destino='Estados Unidos', medio_transporte='Marítimo'  WHERE numero_pedimento='24 04 3991 4 000004' AND incoterm IS NULL",
                "UPDATE pedimento SET incoterm='FOB', tipo_cambio=17.90, pais_destino='México',         medio_transporte='Terrestre' WHERE numero_pedimento='24 05 3991 4 000005' AND incoterm IS NULL",
                "UPDATE pedimento SET incoterm='CFR', tipo_cambio=18.05, pais_destino='Canadá',         medio_transporte='Marítimo'  WHERE numero_pedimento='24 06 3991 4 000006' AND incoterm IS NULL",
                "UPDATE pedimento SET incoterm='CIF', tipo_cambio=17.75, pais_destino='México',         medio_transporte='Terrestre' WHERE numero_pedimento='24 07 3991 4 000007' AND incoterm IS NULL",
                "UPDATE pedimento SET incoterm='DAP', tipo_cambio=18.20, pais_destino='Estados Unidos', medio_transporte='Aéreo'     WHERE numero_pedimento='24 08 3991 4 000008' AND incoterm IS NULL",
                "UPDATE pedimento SET incoterm='FOB', tipo_cambio=17.95, pais_destino='México',         medio_transporte='Terrestre' WHERE numero_pedimento='24 09 3991 4 000009' AND incoterm IS NULL",
                "UPDATE pedimento SET incoterm='EXW', tipo_cambio=18.40, pais_destino='Japón',          medio_transporte='Marítimo'  WHERE numero_pedimento='24 10 3991 4 000010' AND incoterm IS NULL",
                "UPDATE pedimento SET pais_destino='Estados Unidos' WHERE numero_pedimento='26 05 3991 6 000012' AND pais_destino IS NULL",
            ],
            reverse_sql=migrations.RunSQL.noop,
        ),
    ]

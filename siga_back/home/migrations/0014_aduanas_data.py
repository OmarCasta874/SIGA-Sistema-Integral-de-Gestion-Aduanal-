from django.db import migrations


ADUANAS_SQL = """
INSERT IGNORE INTO aduana (codigo, ciudad, nombre) VALUES
    (1,  'Tijuana',             'Aduana de Tijuana'),
    (2,  'Ciudad Juárez',       'Aduana de Ciudad Juárez'),
    (3,  'Nuevo Laredo',        'Aduana de Nuevo Laredo'),
    (4,  'Manzanillo',          'Aduana de Manzanillo'),
    (5,  'Veracruz',            'Aduana de Veracruz'),
    (6,  'Lázaro Cárdenas',     'Aduana de Lázaro Cárdenas'),
    (7,  'Monterrey',           'Aduana de Monterrey (Aeropuerto)'),
    (8,  'Ciudad de México',    'Aduana del Aeropuerto Internacional AICM'),
    (9,  'Nogales',             'Aduana de Nogales'),
    (10, 'Matamoros',           'Aduana de Matamoros'),
    (11, 'San Luis Potosí',     'Aduana de San Luis Potosí'),
    (12, 'Sonora',              'Aduana de Sonora'),
    (13, 'Culiacán',            'Aduana de Culiacán'),
    (14, 'Puebla',              'Aduana de Puebla'),
    (15, 'La Paz',              'Aduana de La Paz'),
    (16, 'Tampico',             'Aduana de Tampico'),
    (17, 'Altamira',            'Aduana de Altamira'),
    (18, 'Tapachula',           'Aduana de Tapachula'),
    (19, 'Ciudad Hidalgo',      'Aduana de Ciudad Hidalgo');
"""

REVERSE_SQL = """
DELETE FROM aduana WHERE codigo IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
"""


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0013_estado_operaciones_con_pago'),
    ]

    operations = [
        migrations.RunSQL(sql=ADUANAS_SQL, reverse_sql=REVERSE_SQL),
    ]

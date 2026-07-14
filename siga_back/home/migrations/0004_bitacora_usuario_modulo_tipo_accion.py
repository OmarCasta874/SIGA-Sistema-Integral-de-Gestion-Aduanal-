from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0003_usuario_rol_activo'),
    ]

    operations = [
        migrations.RunSQL(
            sql=[
                "ALTER TABLE bitacora ADD COLUMN usuario_id INT NULL;",
                "ALTER TABLE bitacora ADD COLUMN modulo VARCHAR(50) NOT NULL DEFAULT '';",
                "ALTER TABLE bitacora ADD COLUMN tipo_accion VARCHAR(20) NOT NULL DEFAULT '';",
                "ALTER TABLE bitacora ADD CONSTRAINT fk_bitacora_usuario "
                "FOREIGN KEY (usuario_id) REFERENCES usuario(ID_usuario) ON DELETE SET NULL;",
            ],
            reverse_sql=[
                "ALTER TABLE bitacora DROP FOREIGN KEY fk_bitacora_usuario;",
                "ALTER TABLE bitacora DROP COLUMN usuario_id;",
                "ALTER TABLE bitacora DROP COLUMN modulo;",
                "ALTER TABLE bitacora DROP COLUMN tipo_accion;",
            ],
        ),
    ]

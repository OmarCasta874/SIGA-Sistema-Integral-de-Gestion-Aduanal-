(function () {
    const STORAGE_KEY = 'siga-sidebar-colapsado';

    function aplicarEstado(colapsado) {
        document.body.classList.toggle('sidebar-colapsado', colapsado);
    }

    aplicarEstado(localStorage.getItem(STORAGE_KEY) === '1');

    document.addEventListener('DOMContentLoaded', function () {
        const btnToggle = document.querySelector('.sidebar-toggle');
        if (!btnToggle) return;

        btnToggle.addEventListener('click', function () {
            const colapsado = !document.body.classList.contains('sidebar-colapsado');
            aplicarEstado(colapsado);
            localStorage.setItem(STORAGE_KEY, colapsado ? '1' : '0');
        });
    });
})();
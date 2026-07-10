/** @type {import('tailwindcss').Config} */
module.exports = {
    content: ['./admin/views/**/*.html', './admin/js/**/*.js'],
    theme: {
        extend: {
            colors: {
                primary: '#C6FF00',
                secondary: '#00E5FF',
                tertiary: '#D9EFFF',
                neutral: '#0A0A0A'
            }
        }
    },
    plugins: []
};

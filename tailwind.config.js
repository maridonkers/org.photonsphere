module.exports = {
    content: [
        './templates/**/*.{html,js}',
        './pages/*.org',
        './posts/*.org',
    ],
    theme: {
        // colors: {
        //     grey: {
        //         100: "#F5F7FA",
        //         1000: "#1F2933"
        //     },
        // },
        typography: (theme) => ({
            DEFAULT: {
                css: {
                    figure: {
                        marginTop: '0px',
                        marginBottom: '10px',
                    },
                    img: {
                        marginTop: '0px',
                        marginBottom: '0px',
                    },
                    p: {
                        marginTop: '0px',
                        marginBottom: '10px',
                    },
                    ul: {
                        marginTop: '0px',
                        marginBottom: '20px',
                    },
                    li: {
                        marginTop: '0px',
                        marginBottom: '1px',
                    },
                    h1: {
                        fontSize: theme('fontSize.xl')[0],
                        color: theme('colors.gray[700]'),
                        marginTop: '30px',
                        marginBottom: '10px',
                    },
                    h2: {
                        fontSize: theme('fontSize.lg')[0],
                        color: theme('colors.gray[700]'),
                        marginTop: '15px',
                        marginBottom: '10px',
                    },
                    h3: {
                        fontSize: theme('fontSize.base')[0],
                        color: theme('colors.black'),
                        marginTop: '10px',
                        marginBottom: '10px',
                    },
                    h4: {
                        fontSize: theme('fontSize.sm')[0],
                        color: theme('colors.black'),
                        marginTop: '10px',
                        marginBottom: '10px',
                    },
                    h5: {
                        fontSize: theme('fontSize.sm')[0],
                        color: theme('colors.black'),
                        marginTop: '10px',
                        marginBottom: '10px',
                    },
                    a: {
			color: theme('colors.red.800'),
			fontWeight: theme('fontWeight.medium'),
			textDecoration: 'none',
			boxShadow: theme('boxShadow.link'),
		    },
                },
            },
        }),
    },
    darkMode: 'media',
    experimental: {
        extendedFontSizeScale: true,
    },
    plugins: [
        require('@tailwindcss/typography'),
    ],
}

const colors = require("tailwindcss/colors");

module.exports = {
  mode: "jit",
  purge: [
    "../lib/**/*.ex",
    "../lib/**/*.leex",
    "../lib/**/*.eex",
    "./js/**/*.js",
  ],

  theme: {
    extend: {
      colors: {
        "light-blue": colors.lightBlue,
        teal: colors.teal,
      },
    },
  },
  variants: {
    extend: {
      display: ["last"],
      visibility: ["last"],
    },
  },
  plugins: [require("@tailwindcss/forms")],
};

module.exports = {
  purge: [
    "../lib/**/*.ex",
    "../lib/**/*.leex",
    "../lib/**/*.eex",
    "./js/**/*.js",
  ],
  theme: {},
  variants: {
    extend: {
      display: ["last"],
      visibility: ["last"],
    },
  },
  plugins: [require("@tailwindcss/forms")],
};

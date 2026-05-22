import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Required for Docker networking to expose the app outside the container
    host: true, 
    port: 5173,
    watch: {
      // Enables hot-reloading inside a Docker volume
      usePolling: true
    }
  }
})
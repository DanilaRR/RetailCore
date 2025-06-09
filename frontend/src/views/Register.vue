<template>
  <div class="register-container">
    <h2>Register</h2>
    <form @submit.prevent="register">
      <div>
        <label for="username">Username:</label>
        <input type="text" id="username" v-model="form.username" required />
      </div>

      <div>
        <label for="email">Email:</label>
        <input type="email" id="email" v-model="form.email" required />
      </div>

      <div>
        <label for="password">Password:</label>
        <input type="password" id="password" v-model="form.password" required />
      </div>

      <button type="submit" :disabled="loading">
        {{ loading ? "Registering..." : "Register" }}
      </button>

      <p v-if="message">{{ message }}</p>

      <p>
        Already have an account? 
        <router-link to="/login">Login here</router-link>
      </p>
    </form>
  </div>
</template>
  
  <script setup lang="ts">
  import { ref } from 'vue';
  import axios from 'axios';
  
  const form = ref({
    username: '',
    email: '',
    password: '',
  });
  
  const message = ref<string | null>(null);
  const loading = ref(false);
  
  const register = async () => {
  try {
    const response = await axios.post('http://localhost:8082/api/auth/register', form.value, {
      headers: { 'Content-Type': 'application/json' }
    });
    message.value = response.data; // Show success or error message
  } catch (error: any) {
    if (error.response && error.response.status === 400) {
      message.value = error.response.data;
    } else {
      message.value = 'Registration failed! Please try again.';
    }
    console.error('Registration error:', error);
  }
};

  </script>
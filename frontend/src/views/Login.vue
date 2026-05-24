<template>
  <div class="login-container">
    <h2>Login</h2>
    <form @submit.prevent="login">
      <div>
        <label for="email">Email:</label>
        <input type="email" id="email" v-model="form.email" required />
      </div>

      <div>
        <label for="password">Password:</label>
        <input type="password" id="password" v-model="form.password" required />
      </div>

      <button type="submit" :disabled="loading">
        {{ loading ? "Logging in..." : "Login" }}
      </button>

      <p v-if="message" :class="{ error: isError }">{{ message }}</p>

      <p>
        Don't have an account?
        <router-link to="/register">Register here</router-link>
      </p>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';

const router = useRouter();

const form = ref({
  email: '',
  password: '',
});

const message = ref<string | null>(null);
const loading = ref(false);
const isError = ref(false);

const login = async () => {
  try {
    loading.value = true;
    isError.value = false;
    const response = await axios.post('http://localhost:8082/api/auth/login', form.value, {
      headers: { 'Content-Type': 'application/json' }
    });

    // Store the token
    localStorage.setItem('token', response.data);
    message.value = 'Login successful! Redirecting...';

    // Redirect to home after a short delay
    setTimeout(() => {
      router.push('/home');
    }, 500);
  } catch (error: any) {
    isError.value = true;
    if (error.response && error.response.status === 401) {
      message.value = error.response.data || 'Invalid email or password';
    } else if (error.response && error.response.status === 400) {
      message.value = error.response.data;
    } else {
      message.value = 'Login failed! Please try again.';
    }
    console.error('Login error:', error);
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.login-container {
  max-width: 400px;
  margin: 50px auto;
  padding: 20px;
  border: 1px solid #ccc;
  border-radius: 8px;
}

form div {
  margin-bottom: 15px;
}

label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}

input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  box-sizing: border-box;
}

button {
  width: 100%;
  padding: 10px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
}

button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

button:hover:not(:disabled) {
  background-color: #0056b3;
}

p {
  margin-top: 15px;
  text-align: center;
}

p.error {
  color: red;
  font-weight: bold;
}

a {
  color: #007bff;
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}
</style>


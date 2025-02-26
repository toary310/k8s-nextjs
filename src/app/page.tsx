export default function Home() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-8">
      <main className="text-center">
        <h1 className="text-4xl font-bold mb-4">
          Welcome to K8s NextJS App
        </h1>
        <p className="text-xl text-gray-600 dark:text-gray-400">
          This is a microservice application running on Kubernetes
        </p>
        <div className="mt-8 p-4 bg-gray-100 dark:bg-gray-800 rounded-lg">
          <p className="text-sm">
            Environment: {process.env.NODE_ENV}
          </p>
        </div>
      </main>
    </div>
  );
}

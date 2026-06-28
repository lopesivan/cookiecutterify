package {{ cookiecutter.package_name }}

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.TextView
import {{ cookiecutter.package_name }}.databinding.ActivityMainBinding

class {{ cookiecutter.main_activity }} : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Example of a call to a native method
        binding.sampleText.text = {{ cookiecutter.java_jni_method }}()
    }

    /**
     * A native method that is implemented by the '{{ cookiecutter.__app_name_without_space_lower }}' native library,
     * which is packaged with this application.
     */
    external fun {{ cookiecutter.java_jni_method }}(): String

    companion object {
        // Used to load the '{{ cookiecutter.__app_name_without_space_lower }}' library on application startup.
        init {
            System.loadLibrary("{{ cookiecutter.__app_name_without_space_lower }}")
        }
    }
}
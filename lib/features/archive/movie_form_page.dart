import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_archive/core/utils/validators.dart';
import 'package:movie_archive/core/widgets/app_button.dart';
import 'package:movie_archive/core/widgets/app_text_field.dart';
import 'package:movie_archive/core/widgets/app_top_bar.dart';
import 'package:movie_archive/core/widgets/state_views.dart';
import 'package:movie_archive/data/models/movie.dart';
import 'package:movie_archive/data/repositories/movie_repository.dart';

// Formulario único para "Nueva película" y "Editar película". Sin `movieId` crea; con `movieId` precarga los datos y actualiza.
class MovieFormPage extends StatefulWidget {
  const MovieFormPage({super.key, this.movieId});

  final String? movieId;

  @override
  State<MovieFormPage> createState() => _MovieFormPageState();
}

class _MovieFormPageState extends State<MovieFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrl = TextEditingController();
  final _title = TextEditingController();
  final _year = TextEditingController();
  final _director = TextEditingController();
  final _synopsis = TextEditingController();
  String? _genre;

  late bool _loading;
  bool _loadFailed = false;
  bool _saving = false;

  bool get _isEdit => widget.movieId != null;

  @override
  void initState() {
    super.initState();
    _loading = _isEdit;
    if (_isEdit) _loadMovie();
  }

  @override
  void dispose() {
    _imageUrl.dispose();
    _title.dispose();
    _year.dispose();
    _director.dispose();
    _synopsis.dispose();
    super.dispose();
  }

  Future<void> _loadMovie() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final movie = await movieRepository.getById(widget.movieId!);
      if (!mounted) return;
      if (movie == null) {
        setState(() {
          _loadFailed = true;
          _loading = false;
        });
        return;
      }
      _imageUrl.text = movie.imageUrl;
      _title.text = movie.title;
      _year.text = movie.year.toString();
      _director.text = movie.director;
      _synopsis.text = movie.synopsis;
      setState(() {
        _genre = movie.genre;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final movie = Movie(
        id: widget.movieId ?? '',
        title: _title.text.trim(),
        year: int.parse(_year.text.trim()),
        director: _director.text.trim(),
        genre: _genre!,
        synopsis: _synopsis.text.trim(),
        imageUrl: _imageUrl.text.trim(),
      );
      await movieRepository.save(movie);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Película actualizada' : 'Película guardada'),
        ),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar. Inténtalo de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: _isEdit ? 'Editar película' : 'Nueva película',
        showBack: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView();
    if (_loadFailed) {
      return ErrorView(
        message: 'No se pudo cargar la película.',
        onRetry: _loadMovie,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'URL de la imagen',
              controller: _imageUrl,
              hint: 'https://res.cloudinary.com/...',
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              enabled: !_saving,
              validator: Validators.imageUrl,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Título',
              controller: _title,
              textInputAction: TextInputAction.next,
              enabled: !_saving,
              validator: (v) =>
                  Validators.notEmpty(v, message: 'Escribe el título'),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: AppTextField(
                    label: 'Año',
                    controller: _year,
                    hint: '1982',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    enabled: !_saving,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: Validators.year,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Género'),
                      DropdownButtonFormField<String>(
                        initialValue: _genre,
                        isExpanded: true,
                        decoration: appInputDecoration(hint: 'Elige'),
                        items: [
                          for (final genre in kGenres)
                            DropdownMenuItem<String>(
                              value: genre,
                              child: Text(genre),
                            ),
                        ],
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _genre = value),
                        validator: (value) =>
                            value == null ? 'Elige un género' : null,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Director',
              controller: _director,
              textInputAction: TextInputAction.next,
              enabled: !_saving,
              validator: (v) =>
                  Validators.notEmpty(v, message: 'Escribe el director'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Sinopsis',
              controller: _synopsis,
              minLines: 4,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              enabled: !_saving,
              validator: (v) =>
                  Validators.notEmpty(v, message: 'Escribe la sinopsis'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton.success(
                    label: _saving ? 'Guardando…' : 'Guardar',
                    onPressed: _saving ? null : _save,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.danger(
                    label: 'Cancelar',
                    onPressed: _saving ? null : () => context.pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
